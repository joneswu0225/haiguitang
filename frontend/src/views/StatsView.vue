<template>
  <div class="max-w-6xl mx-auto space-y-8">
    <div class="flex items-center justify-between">
      <div>
        <h2 class="text-3xl font-bold text-amber-400 mb-2">个人统计</h2>
        <p class="text-gray-400">查看你的游戏表现和进步趋势</p>
      </div>
      <button class="btn-secondary flex items-center space-x-2" @click="$router.push('/')">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
        </svg>
        <span>返回大厅</span>
      </button>
    </div>
    
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="card text-center">
        <div class="text-4xl font-bold text-amber-400 mb-2">{{ stats.completedGames }}</div>
        <div class="text-gray-300 font-medium">已完成局数</div>
        <div class="text-gray-500 text-sm mt-1">仅统计 completed 状态</div>
      </div>
      
      <div class="card text-center">
        <div class="text-4xl font-bold text-amber-400 mb-2">{{ formatTime(stats.averageTimeSeconds) }}</div>
        <div class="text-gray-300 font-medium">平均用时</div>
        <div class="text-gray-500 text-sm mt-1">每局平均推理时间</div>
      </div>
      
      <div class="card text-center">
        <div class="text-4xl font-bold text-amber-400 mb-2">{{ stats.successRate }}%</div>
        <div class="text-gray-300 font-medium">成功率</div>
        <div class="text-gray-500 text-sm mt-1">接近度评分 ≥ 60</div>
      </div>
      
      <div class="card text-center">
        <div class="text-4xl font-bold text-amber-400 mb-2">{{ stats.totalQuestions }}</div>
        <div class="text-gray-300 font-medium">总提问数</div>
        <div class="text-gray-500 text-sm mt-1">所有游戏提问总数</div>
      </div>
    </div>
    
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
      <div class="card">
        <h3 class="text-xl font-semibold text-gray-100 mb-6">游戏记录</h3>
        <div v-if="recentGames.length === 0" class="text-center py-8 text-gray-500">
          还没有游戏记录
        </div>
        <div v-else class="space-y-4">
          <div v-for="game in recentGames" :key="game.id" class="border border-slate-700 rounded-lg p-4 hover:border-amber-400/30 transition-colors">
            <div class="flex justify-between items-start mb-3">
              <div>
                <div class="text-gray-100 font-medium">{{ game.soupTitle }}</div>
                <div class="text-gray-500 text-sm mt-1">{{ formatDate(game.endedAt) }}</div>
              </div>
              <div class="flex items-center space-x-2">
                <span class="px-3 py-1 rounded-full text-sm font-medium" :class="difficultyClass(game.difficulty)">
                  {{ game.difficulty }}
                </span>
                <span class="px-3 py-1 rounded-full text-sm font-medium bg-slate-700 text-gray-300">
                  {{ game.status === 'completed' ? '已完成' : '已放弃' }}
                </span>
              </div>
            </div>
            
            <div class="grid grid-cols-3 gap-4 text-center">
              <div>
                <div class="text-gray-400 text-sm">提问数</div>
                <div class="text-amber-400 font-semibold">{{ game.turnCount }}</div>
              </div>
              <div>
                <div class="text-gray-400 text-sm">用时</div>
                <div class="text-amber-400 font-semibold">{{ game.duration }}</div>
              </div>
              <div>
                <div class="text-gray-400 text-sm">接近度</div>
                <div class="text-amber-400 font-semibold">{{ game.proximityScore || '--' }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div class="card">
        <h3 class="text-xl font-semibold text-gray-100 mb-6">提问分析</h3>
        <div class="space-y-6">
          <div>
            <div class="flex justify-between items-center mb-2">
              <div class="text-gray-300">回答分布</div>
              <div class="text-gray-400 text-sm">{{ answerStats.total }} 次提问</div>
            </div>
            <div class="space-y-3">
              <div class="flex items-center justify-between">
                <div class="flex items-center space-x-2">
                  <div class="w-3 h-3 rounded-full bg-green-500"></div>
                  <span class="text-gray-300">是</span>
                </div>
                <div class="text-amber-400 font-semibold">{{ answerStats.yes }} ({{ answerStats.yesPercent }}%)</div>
              </div>
              <div class="flex items-center justify-between">
                <div class="flex items-center space-x-2">
                  <div class="w-3 h-3 rounded-full bg-red-500"></div>
                  <span class="text-gray-300">不是</span>
                </div>
                <div class="text-amber-400 font-semibold">{{ answerStats.no }} ({{ answerStats.noPercent }}%)</div>
              </div>
              <div class="flex items-center justify-between">
                <div class="flex items-center space-x-2">
                  <div class="w-3 h-3 rounded-full bg-gray-500"></div>
                  <span class="text-gray-300">无关</span>
                </div>
                <div class="text-amber-400 font-semibold">{{ answerStats.irrelevant }} ({{ answerStats.irrelevantPercent }}%)</div>
              </div>
            </div>
          </div>
          
          <div class="pt-6 border-t border-slate-700">
            <div class="text-gray-300 font-medium mb-4">进步趋势</div>
            <div class="space-y-4">
              <div class="flex items-center justify-between">
                <span class="text-gray-400">最近5局平均接近度</span>
                <span class="text-amber-400 font-semibold">{{ trendStats.recentAvgScore }}分</span>
              </div>
              <div class="flex items-center justify-between">
                <span class="text-gray-400">历史平均接近度</span>
                <span class="text-amber-400 font-semibold">{{ trendStats.historicalAvgScore }}分</span>
              </div>
              <div class="flex items-center justify-between">
                <span class="text-gray-400">进步幅度</span>
                <span :class="trendStats.improvement >= 0 ? 'text-green-400' : 'text-red-400'" class="font-semibold">
                  {{ trendStats.improvement >= 0 ? '+' : '' }}{{ trendStats.improvement }}分
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <div class="card">
      <h3 class="text-xl font-semibold text-gray-100 mb-4">统计说明</h3>
      <ul class="text-gray-400 space-y-2">
        <li class="flex items-start">
          <span class="text-amber-400 mr-2">•</span>
          <span>仅统计 <code class="text-gray-300">completed</code> 状态的游戏，<code class="text-gray-300">abandoned</code> 状态不计入统计</span>
        </li>
        <li class="flex items-start">
          <span class="text-amber-400 mr-2">•</span>
          <span>接近度评分范围 0-100 分，反映提问与汤底关键事实的相关性</span>
        </li>
        <li class="flex items-start">
          <span class="text-amber-400 mr-2">•</span>
          <span>成功率 = (接近度 ≥ 60 的游戏数) ÷ 总游戏数 × 100%</span>
        </li>
        <li class="flex items-start">
          <span class="text-amber-400 mr-2">•</span>
          <span>所有统计仅针对当前用户，不同用户数据隔离</span>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const stats = ref({
  completedGames: 12,
  averageTimeSeconds: 512, // 8分32秒
  successRate: 75,
  totalQuestions: 156
})

const recentGames = ref([
  {
    id: '1',
    soupTitle: '消失的乘客',
    difficulty: '简单',
    status: 'completed',
    endedAt: '2024-01-15T14:30:00Z',
    turnCount: 4,
    duration: '8分15秒',
    proximityScore: 85
  },
  {
    id: '2',
    soupTitle: '雨夜凶杀',
    difficulty: '中等',
    status: 'completed',
    endedAt: '2024-01-14T16:45:00Z',
    turnCount: 6,
    duration: '12分30秒',
    proximityScore: 72
  },
  {
    id: '3',
    soupTitle: '密室之谜',
    difficulty: '困难',
    status: 'abandoned',
    endedAt: '2024-01-13T11:20:00Z',
    turnCount: 3,
    duration: '5分45秒',
    proximityScore: null
  },
  {
    id: '4',
    soupTitle: '时间旅行者',
    difficulty: '中等',
    status: 'completed',
    endedAt: '2024-01-12T20:15:00Z',
    turnCount: 5,
    duration: '10分20秒',
    proximityScore: 68
  }
])

const answerStats = computed(() => {
  const total = 156
  const yes = 78
  const no = 52
  const irrelevant = 26
  
  return {
    total,
    yes,
    no,
    irrelevant,
    yesPercent: Math.round((yes / total) * 100),
    noPercent: Math.round((no / total) * 100),
    irrelevantPercent: Math.round((irrelevant / total) * 100)
  }
})

const trendStats = computed(() => {
  const recentAvgScore = 78
  const historicalAvgScore = 72
  const improvement = recentAvgScore - historicalAvgScore
  
  return {
    recentAvgScore,
    historicalAvgScore,
    improvement
  }
})

const difficultyClass = (difficulty: string) => {
  switch (difficulty) {
    case '简单': return 'bg-green-900/30 text-green-400'
    case '中等': return 'bg-yellow-900/30 text-yellow-400'
    case '困难': return 'bg-red-900/30 text-red-400'
    default: return 'bg-slate-700 text-gray-300'
  }
}

const formatTime = (seconds: number) => {
  const minutes = Math.floor(seconds / 60)
  const remainingSeconds = seconds % 60
  return `${minutes}分${remainingSeconds.toString().padStart(2, '0')}秒`
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}
</script>