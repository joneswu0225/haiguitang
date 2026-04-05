<template>
  <div class="max-w-4xl mx-auto space-y-8">
    <div class="flex items-center justify-between">
      <div>
        <h2 class="text-3xl font-bold text-amber-400 mb-2">关于 AI 海龟汤</h2>
        <p class="text-gray-400">探索推理与解谜的乐趣</p>
      </div>
      <button class="btn-secondary flex items-center space-x-2" @click="$router.push('/')">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
        </svg>
        <span>返回大厅</span>
      </button>
    </div>
    
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
      <div class="card">
        <h3 class="text-xl font-semibold text-gray-100 mb-4">什么是海龟汤？</h3>
        <div class="space-y-4">
          <p class="text-gray-300 leading-relaxed">
            海龟汤是一种情境推理游戏，由「煲汤人」和「喝汤人」组成。煲汤人掌握一个完整但离奇的事件（汤底），喝汤人只能看到不完整的事件描述（汤面），通过提出封闭式问题（只能回答是/不是/无关）来逐步还原真相。
          </p>
          <p class="text-gray-300 leading-relaxed">
            传统海龟汤需要真人担任煲汤人，而 AI 海龟汤使用人工智能作为裁判，让玩家可以随时单人开局，享受推理的乐趣。
          </p>
        </div>
      </div>
      
      <div class="card">
        <h3 class="text-xl font-semibold text-gray-100 mb-4">游戏规则</h3>
        <ul class="space-y-3">
          <li class="flex items-start">
            <span class="text-amber-400 mr-2">•</span>
            <span class="text-gray-300">玩家只能看到「汤面」（不完整的事件描述）</span>
          </li>
          <li class="flex items-start">
            <span class="text-amber-400 mr-2">•</span>
            <span class="text-gray-300">通过提问获取 AI 裁判的「是/不是/无关」回答</span>
          </li>
          <li class="flex items-start">
            <span class="text-amber-400 mr-2">•</span>
            <span class="text-gray-300">推理过程中不会显示接近度评分，避免剧透</span>
          </li>
          <li class="flex items-start">
            <span class="text-amber-400 mr-2">•</span>
            <span class="text-gray-300">完成游戏后可查看「汤底」和每问接近度分析</span>
          </li>
          <li class="flex items-start">
            <span class="text-amber-400 mr-2">•</span>
            <span class="text-gray-300">放弃游戏不计入统计，也无法查看汤底</span>
          </li>
        </ul>
      </div>
    </div>
    
    <div class="card">
      <h3 class="text-xl font-semibold text-gray-100 mb-4">技术架构</h3>
      <div class="space-y-6">
        <div>
          <h4 class="text-gray-300 font-medium mb-2">前端技术栈</h4>
          <div class="flex flex-wrap gap-2">
            <span class="px-3 py-1 rounded-full text-sm bg-slate-700 text-gray-300">Vue 3</span>
            <span class="px-3 py-1 rounded-full text-sm bg-slate-700 text-gray-300">TypeScript</span>
            <span class="px-3 py-1 rounded-full text-sm bg-slate-700 text-gray-300">Vite</span>
            <span class="px-3 py-1 rounded-full text-sm bg-slate-700 text-gray-300">Tailwind CSS</span>
            <span class="px-3 py-1 rounded-full text-sm bg-slate-700 text-gray-300">Vue Router</span>
            <span class="px-3 py-1 rounded-full text-sm bg-slate-700 text-gray-300">Pinia</span>
          </div>
        </div>
        
        <div>
          <h4 class="text-gray-300 font-medium mb-2">后端技术栈</h4>
          <div class="flex flex-wrap gap-2">
            <span class="px-3 py-1 rounded-full text-sm bg-slate-700 text-gray-300">Python</span>
            <span class="px-3 py-1 rounded-full text-sm bg-slate-700 text-gray-300">FastAPI</span>
            <span class="px-3 py-1 rounded-full text-sm bg-slate-700 text-gray-300">SQLite</span>
            <span class="px-3 py-1 rounded-full text-sm bg-slate-700 text-gray-300">DeepSeek API</span>
            <span class="px-3 py-1 rounded-full text-sm bg-slate-700 text-gray-300">Pydantic</span>
          </div>
        </div>
        
        <div>
          <h4 class="text-gray-300 font-medium mb-2">安全设计</h4>
          <ul class="text-gray-400 space-y-2">
            <li class="flex items-start">
              <span class="text-amber-400 mr-2">•</span>
              <span>API Key 仅存在于后端环境变量，前端不持有敏感信息</span>
            </li>
            <li class="flex items-start">
              <span class="text-amber-400 mr-2">•</span>
              <span>用户数据隔离，不同用户统计独立</span>
            </li>
            <li class="flex items-start">
              <span class="text-amber-400 mr-2">•</span>
              <span>汤底仅在服务端处理，不下发浏览器</span>
            </li>
          </ul>
        </div>
      </div>
    </div>
    
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
      <div class="card">
        <h3 class="text-xl font-semibold text-gray-100 mb-4">评分系统</h3>
        <div class="space-y-4">
          <p class="text-gray-300">
            每局游戏结束后，系统会对每个提问进行接近度评分（0-100分），反映该问题与汤底关键事实的相关性。
          </p>
          <div class="space-y-2">
            <div class="flex items-center justify-between">
              <span class="text-gray-400">80-100分</span>
              <span class="text-green-400">优秀：直接触及核心事实</span>
            </div>
            <div class="flex items-center justify-between">
              <span class="text-gray-400">60-79分</span>
              <span class="text-yellow-400">良好：接近关键线索</span>
            </div>
            <div class="flex items-center justify-between">
              <span class="text-gray-400">40-59分</span>
              <span class="text-orange-400">一般：相关但不够直接</span>
            </div>
            <div class="flex items-center justify-between">
              <span class="text-gray-400">0-39分</span>
              <span class="text-red-400">待改进：偏离推理方向</span>
            </div>
          </div>
          <p class="text-gray-500 text-sm italic">
            评分仅供参考，推理过程才是真正的乐趣所在。
          </p>
        </div>
      </div>
      
      <div class="card">
        <h3 class="text-xl font-semibold text-gray-100 mb-4">开发团队与开源</h3>
        <div class="space-y-4">
          <p class="text-gray-300">
            AI 海龟汤是一个开源项目，遵循 MIT 许可证。项目代码完全公开，欢迎开发者参与贡献。
          </p>
          <div class="space-y-2">
            <div class="flex items-center space-x-2">
              <svg class="w-5 h-5 text-gray-400" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
              </svg>
              <span class="text-gray-300">GitHub: ai-haiguitang</span>
            </div>
            <div class="flex items-center space-x-2">
              <svg class="w-5 h-5 text-gray-400" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
              </svg>
              <span class="text-gray-300">开发团队：AI 海龟汤项目组</span>
            </div>
            <div class="flex items-center space-x-2">
              <svg class="w-5 h-5 text-gray-400" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
              </svg>
              <span class="text-gray-300">许可证：MIT</span>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <div class="card">
      <div class="text-center">
        <h3 class="text-xl font-semibold text-gray-100 mb-4">开始你的推理之旅</h3>
        <p class="text-gray-400 mb-6">选择一道海龟汤谜题，开始挑战 AI 裁判的推理能力吧！</p>
        <button class="btn-primary" @click="$router.push('/')">
          前往游戏大厅
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'

const router = useRouter()
</script>