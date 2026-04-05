<template>
  <div class="max-w-4xl mx-auto space-y-8">
    <div class="flex items-center justify-between">
      <button class="btn-secondary flex items-center space-x-2" @click="$router.push('/')">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
        </svg>
        <span>返回大厅</span>
      </button>
      <div class="text-right">
        <div class="text-gray-400 text-sm">游戏ID: {{ gameId }}</div>
        <div class="text-green-400 font-semibold">已完成</div>
      </div>
    </div>
    
    <div class="text-center">
      <h2 class="text-3xl font-bold text-amber-400 mb-2">汤底揭晓</h2>
      <p class="text-gray-400">恭喜你完成了这局游戏！以下是完整的真相和你的推理表现分析。</p>
    </div>
    
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
      <div class="space-y-6">
        <div class="card">
          <h3 class="text-xl font-semibold text-gray-100 mb-4">汤面回顾</h3>
          <p class="text-gray-300 text-lg leading-relaxed">{{ currentSoup?.surface }}</p>
          <div class="mt-4 flex items-center space-x-4">
            <span class="px-3 py-1 rounded-full text-sm font-medium" :class="difficultyClass(currentSoup?.difficulty || '中等')">
              {{ currentSoup?.difficulty }}
            </span>
            <span class="text-gray-400">游戏时长: {{ gameDuration }}</span>
          </div>
        </div>
        
        <div class="card">
          <h3 class="text-xl font-semibold text-gray-100 mb-4">汤底真相</h3>
          <div class="bg-slate-900/50 border border-amber-400/30 rounded-lg p-6">
            <div class="text-amber-400 text-lg font-medium mb-2">完整真相：</div>
            <p class="text-gray-300 leading-relaxed">{{ currentSoup?.bottom }}</p>
          </div>
          <div class="mt-4">
            <div class="text-amber-400 font-medium mb-2">关键事实：</div>
            <ul class="space-y-2">
              <li v-for="(fact, index) in currentSoup?.key_facts" :key="index" class="flex items-start">
                <span class="text-amber-400 mr-2">•</span>
                <span class="text-gray-300">{{ fact }}</span>
              </li>
            </ul>
          </div>
        </div>
      </div>
      
      <div class="space-y-6">
        <div class="card">
          <h3 class="text-xl font-semibold text-gray-100 mb-4">推理表现</h3>
          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <div>
                <div class="text-gray-400">整体接近度</div>
                <div class="text-2xl font-bold text-amber-400">{{ overallScore }}分</div>
              </div>
              <div class="text-right">
                <div class="text-gray-400">提问数量</div>
                <div class="text-2xl font-bold text-amber-400">{{ turns.length }}</div>
              </div>
            </div>
            
            <div class="bg-slate-900/50 rounded-lg p-4">
              <div class="text-gray-400 text-sm mb-2">评分理由：</div>
              <p class="text-gray-300 text-sm">{{ overallRationale }}</p>
            </div>
            
            <div class="text-gray-500 text-sm text-center italic">
              <p>评分仅供参考，推理过程才是真正的乐趣所在</p>
            </div>
          </div>
        </div>
        
        <div class="card">
          <h3 class="text-xl font-semibold text-gray-100 mb-4">每问接近度分析</h3>
          <div v-if="turns.length === 0" class="text-center py-8 text-gray-500">
            没有提问记录
          </div>
          <div v-else class="space-y-4">
            <div v-for="turn in turns" :key="turn.id" class="border border-slate-700 rounded-lg p-4">
              <div class="flex justify-between items-start mb-3">
                <div class="text-gray-300 font-medium">{{ turn.question }}</div>
                <div class="flex items-center space-x-2">
                  <span class="px-3 py-1 rounded-full text-sm font-medium" :class="answerBadgeClass(turn.answer)">
                    {{ formatAnswer(turn.answer) }}
                  </span>
                </div>
              </div>
              
              <div class="flex items-center justify-between mb-2">
                <div class="text-gray-400 text-sm">接近度评分</div>
                <div class="flex items-center space-x-2">
                  <div class="text-amber-400 font-bold">{{ turn.proximity_score || 0 }}分</div>
                  <div class="w-32 h-2 bg-slate-700 rounded-full overflow-hidden">
                    <div 
                      class="h-full rounded-full" 
                      :class="scoreColorClass(turn.proximity_score || 0)"
                      :style="{ width: `${turn.proximity_score || 0}%` }"
                    ></div>
                  </div>
                </div>
              </div>
              
              <div v-if="turn.proximity_rationale" class="text-gray-400 text-sm">
                {{ turn.proximity_rationale }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <div class="card">
      <div class="flex flex-col md:flex-row items-center justify-between space-y-4 md:space-y-0">
        <div>
          <h3 class="text-xl font-semibold text-gray-100 mb-2">继续挑战</h3>
          <p class="text-gray-400">题库中还有更多有趣的谜题等待你的推理</p>
        </div>
        <div class="flex space-x-3">
          <button class="btn-secondary" @click="$router.push('/')">
            返回大厅
          </button>
          <button class="btn-primary" @click="startNewGame">
            开始新游戏
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import type { TTurn, TSoup } from '@/types'

const props = defineProps<{
  gameId: string
}>()

const router = useRouter()
const turns = ref<TTurn[]>([])
const currentSoup = ref<TSoup | null>(null)
const overallScore = ref(75)
const overallRationale = ref('推理过程良好，接近关键事实，但部分提问偏离了核心线索。')

onMounted(() => {
  loadMockData()
})

const loadMockData = () => {
  currentSoup.value = {
    id: '1',
    title: '消失的乘客',
    surface: '一名乘客在火车上消失了，但火车一直在行驶，没有人看到有人下车。',
    bottom: '乘客是一名魔术师，他在火车行驶时表演了消失魔术，实际上他藏在了行李车厢。',
    key_facts: ['乘客是魔术师', '火车在行驶中', '没有人看到下车', '使用了魔术技巧'],
    difficulty: '简单',
    category: '推理',
    estimatedTime: '10分钟',
    playedCount: 124
  }
  
  turns.value = [
    {
      id: '1',
      game_id: props.gameId,
      question: '这个乘客是不是自己主动消失的？',
      answer: 'yes',
      created_at: new Date(Date.now() - 30 * 60 * 1000).toISOString(),
      proximity_score: 85,
      proximity_rationale: '直接触及了核心事实：乘客是主动消失的。'
    },
    {
      id: '2',
      game_id: props.gameId,
      question: '有没有其他人帮助他消失？',
      answer: 'no',
      created_at: new Date(Date.now() - 25 * 60 * 1000).toISOString(),
      proximity_score: 60,
      proximity_rationale: '虽然排除了外部帮助，但没有直接指向魔术技巧。'
    },
    {
      id: '3',
      game_id: props.gameId,
      question: '火车是不是在隧道里行驶？',
      answer: 'irrelevant',
      created_at: new Date(Date.now() - 20 * 60 * 1000).toISOString(),
      proximity_score: 20,
      proximity_rationale: '与关键事实无关，偏离了推理方向。'
    },
    {
      id: '4',
      game_id: props.gameId,
      question: '乘客是不是有特殊的技能或职业？',
      answer: 'yes',
      created_at: new Date(Date.now() - 15 * 60 * 1000).toISOString(),
      proximity_score: 90,
      proximity_rationale: '非常接近真相，直接指向了魔术师这个关键身份。'
    }
  ]
}

const difficultyClass = (difficulty: string) => {
  switch (difficulty) {
    case '简单': return 'bg-green-900/30 text-green-400'
    case '中等': return 'bg-yellow-900/30 text-yellow-400'
    case '困难': return 'bg-red-900/30 text-red-400'
    default: return 'bg-slate-700 text-gray-300'
  }
}

const answerBadgeClass = (answer: string) => {
  switch (answer) {
    case 'yes': return 'bg-green-900/30 text-green-400'
    case 'no': return 'bg-red-900/30 text-red-400'
    case 'irrelevant': return 'bg-gray-800 text-gray-400'
    default: return 'bg-slate-700 text-gray-300'
  }
}

const formatAnswer = (answer: string) => {
  switch (answer) {
    case 'yes': return '是'
    case 'no': return '不是'
    case 'irrelevant': return '无关'
    default: return answer
  }
}

const scoreColorClass = (score: number) => {
  if (score >= 80) return 'bg-green-500'
  if (score >= 60) return 'bg-yellow-500'
  if (score >= 40) return 'bg-orange-500'
  return 'bg-red-500'
}

const gameDuration = computed(() => {
  if (turns.value.length === 0) return '0分钟'
  const firstTurn = new Date(turns.value[turns.value.length - 1].created_at)
  const lastTurn = new Date(turns.value[0].created_at)
  const diffMinutes = Math.floor((lastTurn.getTime() - firstTurn.getTime()) / (1000 * 60))
  return `${diffMinutes}分钟`
})

const startNewGame = () => {
  router.push('/')
}
</script>