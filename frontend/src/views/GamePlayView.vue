<template>
  <div class="max-w-4xl mx-auto space-y-8">
    <!-- 错误消息 -->
    <div v-if="errorMessage" class="bg-red-900/30 border border-red-700 rounded-lg p-4">
      <div class="flex items-center space-x-3">
        <svg class="w-5 h-5 text-red-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <span class="text-red-300">{{ errorMessage }}</span>
      </div>
    </div>
    
    <!-- 加载状态 -->
    <div v-if="isLoading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-amber-400"></div>
      <p class="mt-4 text-gray-400">加载游戏数据中...</p>
    </div>
    
    <!-- 游戏内容 -->
    <div v-else>
      <div class="flex items-center justify-between">
        <button class="btn-secondary flex items-center space-x-2" @click="$router.push('/')">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
          </svg>
          <span>返回大厅</span>
        </button>
        <div class="text-right">
          <div class="text-gray-400 text-sm">游戏ID: {{ gameId }}</div>
          <div class="text-amber-400 font-semibold">进行中</div>
        </div>
      </div>
    
    <div class="card">
      <h2 class="text-2xl font-bold text-amber-400 mb-4">汤面</h2>
      <p class="text-gray-300 text-lg leading-relaxed">{{ currentSoup?.surface }}</p>
      <div class="mt-4 flex items-center space-x-4">
        <span class="px-3 py-1 rounded-full text-sm font-medium" :class="difficultyClass(currentSoup?.difficulty || '中等')">
          {{ currentSoup?.difficulty }}
        </span>
        <span class="text-gray-400">预计时长: {{ currentSoup?.estimatedTime }}</span>
      </div>
    </div>
    
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <div class="lg:col-span-2 space-y-6">
        <div class="card">
          <h3 class="text-xl font-semibold text-gray-100 mb-4">提问</h3>
          <div class="space-y-4">
            <textarea
              v-model="question"
              placeholder="输入你的问题（例如：这个人是不是还活着？）"
              class="input-primary w-full h-32 resize-none"
              :disabled="isSubmitting"
            ></textarea>
            <div class="flex justify-end space-x-3">
              <button class="btn-secondary" :disabled="isSubmitting || !question.trim()" @click="clearQuestion">
                清空
              </button>
              <button class="btn-primary" :disabled="isSubmitting || !question.trim()" @click="submitQuestion">
                <span v-if="isSubmitting">提交中...</span>
                <span v-else>提交问题</span>
              </button>
            </div>
          </div>
        </div>
        
        <div class="card">
          <h3 class="text-xl font-semibold text-gray-100 mb-4">问答历史</h3>
          <div v-if="turns.length === 0" class="text-center py-8 text-gray-500">
            <svg class="w-12 h-12 mx-auto text-gray-600 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"></path>
            </svg>
            <p>还没有提问，开始你的推理吧！</p>
          </div>
          <div v-else class="space-y-4">
            <div v-for="turn in turns" :key="turn.id" class="border-l-4 pl-4 py-3" :class="answerBorderClass(turn.answer)">
              <div class="flex justify-between items-start mb-2">
                <div class="text-gray-300 font-medium">{{ turn.question }}</div>
                <div class="text-gray-500 text-sm">{{ formatTime(turn.created_at) }}</div>
              </div>
              <div class="flex items-center space-x-2">
                <span class="px-3 py-1 rounded-full text-sm font-medium" :class="answerBadgeClass(turn.answer)">
                  {{ formatAnswer(turn.answer) }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div class="space-y-6">
        <div class="card">
          <h3 class="text-xl font-semibold text-gray-100 mb-4">游戏操作</h3>
          <div class="space-y-3">
            <button class="btn-primary w-full" @click="completeGame">
              查看汤底（完成游戏）
            </button>
            <button class="btn-secondary w-full" @click="abandonGame">
              放弃游戏
            </button>
          </div>
          <div class="mt-6 pt-6 border-t border-slate-700">
            <h4 class="text-gray-300 font-medium mb-2">游戏提示</h4>
            <ul class="text-gray-500 text-sm space-y-2">
              <li class="flex items-start">
                <span class="text-amber-400 mr-2">•</span>
                <span>提问要具体，避免模糊的问题</span>
              </li>
              <li class="flex items-start">
                <span class="text-amber-400 mr-2">•</span>
                <span>AI裁判只会回答「是」、「不是」或「无关」</span>
              </li>
              <li class="flex items-start">
                <span class="text-amber-400 mr-2">•</span>
                <span>推理过程中不会显示接近度评分</span>
              </li>
            </ul>
          </div>
        </div>
        
        <div class="card">
          <h3 class="text-xl font-semibold text-gray-100 mb-4">统计信息</h3>
          <div class="space-y-3">
            <div class="flex justify-between">
              <span class="text-gray-400">已提问次数</span>
              <span class="text-amber-400 font-semibold">{{ turns.length }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-400">游戏时长</span>
              <span class="text-amber-400 font-semibold">{{ gameDuration }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-400">回答分布</span>
              <div class="flex space-x-2">
                <span class="text-green-400">{{ answerCounts.yes }}是</span>
                <span class="text-red-400">{{ answerCounts.no }}否</span>
                <span class="text-gray-400">{{ answerCounts.irrelevant }}无关</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import type { TTurn, TJudgeAnswer, TSoup } from '@/types'
import { gameApi, soupApi, judgeApi } from '@/api/client'

const props = defineProps<{
  gameId: string
}>()

const router = useRouter()
const question = ref('')
const isSubmitting = ref(false)
const turns = ref<TTurn[]>([])
const currentSoup = ref<TSoup | null>(null)
const isLoading = ref(true)
const errorMessage = ref('')

onMounted(() => {
  loadGameData()
})

const loadGameData = async () => {
  isLoading.value = true
  errorMessage.value = ''
  
  try {
    // 1. 加载游戏详情（包含回合数据）
    const gameResponse = await gameApi.getGame(props.gameId)
    const game = gameResponse.data?.game
    
    if (game) {
      // 设置回合数据
      turns.value = game.turns || []
      
      // 2. 加载汤详情
      if (game.soup_id) {
        try {
          const soupResponse = await soupApi.getSoup(game.soup_id)
          currentSoup.value = soupResponse.data?.soup || null
        } catch (soupError) {
          console.warn('加载汤详情失败，使用默认数据:', soupError)
          // 如果加载失败，使用默认数据
          currentSoup.value = getDefaultSoup(game.soup_id)
        }
      }
    } else {
      errorMessage.value = '游戏数据加载失败'
    }
  } catch (error: any) {
    console.error('加载游戏数据失败:', error)
    errorMessage.value = error.message || '加载游戏数据失败，请刷新页面重试'
    
    // 如果API失败，使用模拟数据作为回退
    loadFallbackData()
  } finally {
    isLoading.value = false
  }
}

const getDefaultSoup = (soupId: string): TSoup => {
  const defaultSoups: Record<string, TSoup> = {
    '1': {
      id: '1',
      title: '消失的乘客',
      surface: '一名乘客在火车上消失了，但火车一直在行驶，没有人看到有人下车。',
      bottom: '乘客是一名魔术师，他在火车行驶时表演了消失魔术，实际上他藏在了行李车厢。',
      key_facts: ['乘客是魔术师', '火车在行驶中', '没有人看到下车', '使用了魔术技巧'],
      difficulty: '简单',
      category: '推理',
      estimatedTime: '10分钟',
      playedCount: 124
    },
    '2': {
      id: '2',
      title: '雨夜凶杀',
      surface: '一个雨夜，有人被发现死在公园里，周围没有任何脚印。',
      bottom: '死者是被人从远处用弓箭射杀的，所以周围没有脚印。',
      key_facts: ['雨夜', '公园', '没有脚印', '远程武器'],
      difficulty: '中等',
      category: '悬疑',
      estimatedTime: '15分钟',
      playedCount: 89
    },
    '3': {
      id: '3',
      title: '密室之谜',
      surface: '一个房间从内部反锁，里面的人却消失了，窗户也无法打开。',
      bottom: '房间有密道，密道入口在书架后面。',
      key_facts: ['内部反锁', '窗户无法打开', '密道', '书架'],
      difficulty: '困难',
      category: '密室',
      estimatedTime: '20分钟',
      playedCount: 56
    }
  }
  
  return defaultSoups[soupId] || defaultSoups['1']
}

const loadFallbackData = () => {
  currentSoup.value = getDefaultSoup('1')
  
  // 使用模拟回合数据
  turns.value = [
    {
      id: '1',
      game_id: props.gameId,
      question: '这个乘客是不是自己主动消失的？',
      answer: 'yes',
      created_at: new Date(Date.now() - 30 * 60 * 1000).toISOString()
    },
    {
      id: '2',
      game_id: props.gameId,
      question: '有没有其他人帮助他消失？',
      answer: 'no',
      created_at: new Date(Date.now() - 25 * 60 * 1000).toISOString()
    },
    {
      id: '3',
      game_id: props.gameId,
      question: '火车是不是在隧道里行驶？',
      answer: 'irrelevant',
      created_at: new Date(Date.now() - 20 * 60 * 1000).toISOString()
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

const answerBorderClass = (answer: TJudgeAnswer) => {
  switch (answer) {
    case 'yes': return 'border-green-500'
    case 'no': return 'border-red-500'
    case 'irrelevant': return 'border-gray-500'
  }
}

const answerBadgeClass = (answer: TJudgeAnswer) => {
  switch (answer) {
    case 'yes': return 'bg-green-900/30 text-green-400'
    case 'no': return 'bg-red-900/30 text-red-400'
    case 'irrelevant': return 'bg-gray-800 text-gray-400'
  }
}

const formatAnswer = (answer: TJudgeAnswer) => {
  switch (answer) {
    case 'yes': return '是'
    case 'no': return '不是'
    case 'irrelevant': return '无关'
  }
}

const formatTime = (timestamp: string) => {
  const date = new Date(timestamp)
  return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

const answerCounts = computed(() => {
  return {
    yes: turns.value.filter(t => t.answer === 'yes').length,
    no: turns.value.filter(t => t.answer === 'no').length,
    irrelevant: turns.value.filter(t => t.answer === 'irrelevant').length
  }
})

const gameDuration = computed(() => {
  if (turns.value.length === 0) return '0分钟'
  const firstTurn = new Date(turns.value[0].created_at)
  const now = new Date()
  const diffMinutes = Math.floor((now.getTime() - firstTurn.getTime()) / (1000 * 60))
  return `${diffMinutes}分钟`
})

const clearQuestion = () => {
  question.value = ''
}

const submitQuestion = async () => {
  if (!question.value.trim()) return
  
  isSubmitting.value = true
  errorMessage.value = ''
  
  try {
    // 调用裁判API提交问题
    const response = await judgeApi.judgeQuestion(props.gameId, question.value.trim())
    
    if (response.data?.turn) {
      const newTurn = response.data.turn
      
      // 将新回合添加到列表开头
      turns.value.unshift(newTurn)
      
      // 清空输入框
      question.value = ''
      
      // 检查游戏状态
      if (response.data.game_status === 'completed') {
        // 如果游戏已完成，跳转到复盘页面
        setTimeout(() => {
          router.push({ name: 'review', params: { gameId: props.gameId } })
        }, 1000)
      }
    } else {
      errorMessage.value = '提交问题失败，未收到有效响应'
    }
  } catch (error: any) {
    console.error('提交问题失败:', error)
    errorMessage.value = error.message || '提交问题失败，请重试'
    
    // 如果API失败，使用模拟数据作为回退
    const mockTurn: TTurn = {
      id: Date.now().toString(),
      game_id: props.gameId,
      question: question.value,
      answer: Math.random() > 0.5 ? 'yes' : Math.random() > 0.5 ? 'no' : 'irrelevant',
      created_at: new Date().toISOString()
    }
    
    turns.value.unshift(mockTurn)
    question.value = ''
  } finally {
    isSubmitting.value = false
  }
}

const completeGame = async () => {
  if (!confirm('确定要完成游戏并查看汤底吗？完成游戏后会计入统计。')) {
    return
  }
  
  try {
    // 先调用API完成游戏
    await gameApi.completeGame(props.gameId)
    
    // 等待API调用成功后再导航到review页面
    router.push({ name: 'review', params: { gameId: props.gameId } })
  } catch (error: any) {
    console.error('完成游戏失败:', error)
    errorMessage.value = `完成游戏失败：${error.response?.data?.detail || error.message || '未知错误'}`
  }
}

const abandonGame = async () => {
  if (!confirm('确定要放弃游戏吗？放弃后不会计入统计，也无法查看汤底。')) {
    return
  }
  
  try {
    // 调用API放弃游戏
    await gameApi.abandonGame(props.gameId)
    
    // 放弃游戏后返回大厅
    router.push('/')
  } catch (error: any) {
    console.error('放弃游戏失败:', error)
    errorMessage.value = `放弃游戏失败：${error.response?.data?.detail || error.message || '未知错误'}`
  }
}
</script>