<template>
  <div class="min-h-screen bg-slate-900">
    <header class="border-b border-slate-800">
      <div class="container mx-auto px-4 py-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-2">
            <div class="w-8 h-8 rounded-full bg-amber-400"></div>
            <h1 class="text-2xl font-bold text-amber-400">AI 海龟汤</h1>
          </div>
          <nav class="hidden md:flex space-x-6">
            <router-link to="/" class="text-gray-300 hover:text-amber-400 transition-colors">大厅</router-link>
            <router-link to="/stats" class="text-gray-300 hover:text-amber-400 transition-colors">统计</router-link>
            <router-link to="/about" class="text-gray-300 hover:text-amber-400 transition-colors">关于</router-link>
          </nav>
          <button class="md:hidden text-gray-300">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
            </svg>
          </button>
        </div>
      </div>
    </header>
    
    <main class="container mx-auto px-4 py-8">
      <router-view />
    </main>
    
    <footer class="border-t border-slate-800 mt-12">
      <div class="container mx-auto px-4 py-6">
        <div class="text-center text-gray-500 text-sm">
          <p>AI 海龟汤 © 2024 - 推理与解谜的乐趣</p>
          <p class="mt-2">评分仅供参考，推理过程才是真正的乐趣所在</p>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { RouterLink, RouterView } from 'vue-router'
</script>