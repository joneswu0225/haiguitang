<template>
  <div class="space-y-8">
    <div class="text-center">
      <h2 class="text-3xl font-bold text-amber-400 mb-4">游戏大厅</h2>
      <p class="text-gray-400 max-w-2xl mx-auto">选择一道海龟汤谜题，开始你的推理之旅。AI裁判将根据你的提问给出「是」、「不是」或「无关」的回答。</p>
    </div>
    
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="soup in soups" :key="soup.id" class="card hover:border-amber-400/30 transition-colors cursor-pointer" @click="startGame(soup.id)">
        <div class="flex items-start justify-between mb-4">
          <div>
            <h3 class="text-xl font-semibold text-gray-100 mb-2">{{ soup.title }}</h3>
            <div class="flex items-center space-x-2">
              <span class="px-3 py-1 rounded-full text-xs font-medium" :class="difficultyClass(soup.difficulty)">
                {{ soup.difficulty }}
              </span>
              <span class="px-3 py-1 rounded-full text-xs font-medium bg-slate-700 text-gray-300">
                {{ soup.category }}
              </span>
            </div>
          </div>
          <div class="text-amber-400">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
            </svg>
          </div>
        </div>
        <p class="text-gray-400 text-sm line-clamp-3">{{ soup.surface }}</p>
        <div class="mt-4 pt-4 border-t border-slate-700 flex justify-between items-center">
          <span class="text-gray-500 text-sm">预计时长: {{ soup.estimatedTime }}</span>
          <span class="text-gray-500 text-sm">已玩: {{ soup.playedCount }}次</span>
        </div>
      </div>
    </div>
    
    <div class="card">
      <div class="flex items-center justify-between">
        <div>
          <h3 class="text-xl font-semibold text-gray-100 mb-2">个人统计</h3>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div class="text-center">
              <div class="text-2xl font-bold text-amber-400">{{ stats.completedGames }}</div>
              <div class="text-gray-500 text-sm">已完成局数</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-amber-400">{{ stats.averageTime }}</div>
              <div class="text-gray-500 text-sm">平均用时</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-amber-400">{{ stats.successRate }}%</div>
              <div class="text-gray-500 text-sm">成功率</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-amber-400">{{ stats.totalQuestions }}</div>
              <div class="text-gray-500 text-sm">总提问数</div>
            </div>
          </div>
        </div>
        <button class="btn-primary" @click="$router.push('/stats')">查看详情</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { gameApi } from '@/api/client'
import type { TSoup, TStats } from '@/types'

const router = useRouter()
const isLoading = ref(false)
const errorMessage = ref('')

const soups = ref<TSoup[]>([
  {
    id: '1',
    title: '消失的乘客',
    surface: '一名乘客在火车上消失了，但火车一直在行驶，没有人看到有人下车。',
    bottom: '乘客是一名魔术师，他在火车行驶时表演了消失魔术，实际上他藏在了行李车厢。',
    key_facts: [
      '乘客是魔术师',
      '火车一直在行驶',
      '没有人看到下车',
      '藏在行李车厢'
    ],
    difficulty: '简单',
    category: '推理',
    estimatedTime: '10分钟',
    playedCount: 124
  },
  {
    id: '2',
    title: '雨夜凶杀',
    surface: '一个雨夜，有人被发现死在公园里，周围没有任何脚印。',
    bottom: '死者是被雨伞刺死的，凶手在雨中离开，雨水冲刷了所有脚印。',
    key_facts: [
      '雨夜',
      '公园里发现尸体',
      '周围没有脚印',
      '雨水冲刷痕迹'
    ],
    difficulty: '中等',
    category: '悬疑',
    estimatedTime: '15分钟',
    playedCount: 89
  },
  {
    id: '3',
    title: '密室之谜',
    surface: '一个房间从内部反锁，里面的人却消失了，窗户也无法打开。',
    bottom: '房间有密道，人通过密道离开后从外面反锁了门。',
    key_facts: [
      '房间内部反锁',
      '人消失了',
      '窗户无法打开',
      '存在密道'
    ],
    difficulty: '困难',
    category: '密室',
    estimatedTime: '20分钟',
    playedCount: 56
  },
  {
    id: '4',
    title: '时间旅行者',
    surface: '一个人声称自己来自未来，但他没有任何未来的物品或知识证明。',
    bottom: '这个人有预知未来的能力，但不是时间旅行者，他患有某种神经系统疾病。',
    key_facts: [
      '声称来自未来',
      '没有未来物品',
      '没有未来知识',
      '有预知能力'
    ],
    difficulty: '中等',
    category: '科幻',
    estimatedTime: '15分钟',
    playedCount: 72
  },
  {
    id: '5',
    title: '幽灵信件',
    surface: '一封没有寄信人地址的信出现在邮箱里，内容预言了即将发生的事情。',
    bottom: '信是邻居写的，他通过观察和推理预测了事件，想测试收信人的反应。',
    key_facts: [
      '没有寄信人地址',
      '信预言未来',
      '邻居写的',
      '通过观察推理'
    ],
    difficulty: '困难',
    category: '超自然',
    estimatedTime: '20分钟',
    playedCount: 43
  },
  {
    id: '6',
    title: '双重身份',
    surface: '一个人白天是普通上班族，夜晚却过着完全不同的生活。',
    bottom: '这个人晚上是便衣警察，在执行秘密任务，所以需要隐藏身份。',
    key_facts: [
      '白天上班族',
      '夜晚不同生活',
      '便衣警察',
      '秘密任务'
    ],
    difficulty: '简单',
    category: '社会',
    estimatedTime: '10分钟',
    playedCount: 98
  }
])

const stats = ref<TStats>({
  completedGames: 12,
  averageTime: '8分32秒',
  successRate: 75,
  totalQuestions: 156
})

const difficultyClass = (difficulty: string) => {
  switch (difficulty) {
    case '简单': return 'bg-green-900/30 text-green-400'
    case '中等': return 'bg-yellow-900/30 text-yellow-400'
    case '困难': return 'bg-red-900/30 text-red-400'
    default: return 'bg-slate-700 text-gray-300'
  }
}

const startGame = async (soupId: string) => {
  isLoading.value = true
  errorMessage.value = ''
  
  try {
    // 1. 创建新游戏
    const response = await gameApi.createGame(soupId)
    const game = response.data?.game
    
    if (game && game.id) {
      // 2. 导航到游戏页面
      router.push({ name: 'play', params: { gameId: game.id } })
    } else {
      errorMessage.value = '创建游戏失败：未返回游戏ID'
    }
  } catch (error: any) {
    console.error('创建游戏失败:', error)
    errorMessage.value = `创建游戏失败：${error.response?.data?.detail || error.message || '未知错误'}`
  } finally {
    isLoading.value = false
  }
}
</script>