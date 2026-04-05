import axios from 'axios'
import type { TGame, TTurn, TSoup, TStats, TApiResponse, TJudgeAnswer } from '@/types'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000'

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000,
})

// 请求拦截器：添加用户ID头
apiClient.interceptors.request.use((config) => {
  // 从localStorage获取用户ID，如果没有则生成一个
  let userId = localStorage.getItem('user_id')
  if (!userId) {
    userId = `user-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
    localStorage.setItem('user_id', userId)
  }
  
  // 添加用户ID头
  config.headers['X-User-ID'] = userId
  return config
})

// 响应拦截器：统一处理错误
apiClient.interceptors.response.use(
  (response) => {
    // 直接返回数据部分
    return response.data
  },
  (error) => {
    console.error('API请求错误:', error)
    
    if (error.response) {
      // 服务器返回了错误状态码
      const { status, data } = error.response
      const message = data?.message || `请求失败 (${status})`
      
      return Promise.reject({
        status,
        message,
        data: data?.data,
      })
    } else if (error.request) {
      // 请求已发出但没有收到响应
      return Promise.reject({
        status: 0,
        message: '网络连接错误，请检查网络连接',
        data: null,
      })
    } else {
      // 请求配置出错
      return Promise.reject({
        status: -1,
        message: error.message || '请求配置错误',
        data: null,
      })
    }
  }
)

// 汤相关API
export const soupApi = {
  // 获取所有汤列表
  getSoups: (): Promise<TApiResponse<{ soups: TSoup[] }>> => {
    return apiClient.get('/api/v1/soups/')
  },
  
  // 获取单个汤详情
  getSoup: (soupId: string): Promise<TApiResponse<{ soup: TSoup }>> => {
    return apiClient.get(`/api/v1/soups/${soupId}`)
  },
}

// 游戏相关API
export const gameApi = {
  // 创建新游戏
  createGame: (soupId: string): Promise<TApiResponse<{ game: TGame }>> => {
    return apiClient.post('/api/v1/games/', { soup_id: soupId })
  },
  
  // 获取用户的所有游戏
  getGames: (): Promise<TApiResponse<{ games: TGame[] }>> => {
    return apiClient.get('/api/v1/games/')
  },
  
  // 获取单个游戏详情
  getGame: (gameId: string): Promise<TApiResponse<{ game: TGame }>> => {
    return apiClient.get(`/api/v1/games/${gameId}`)
  },
  
  // 完成游戏
  completeGame: (gameId: string): Promise<TApiResponse<{ game: TGame }>> => {
    return apiClient.patch(`/api/v1/games/${gameId}/complete`)
  },
  
  // 放弃游戏
  abandonGame: (gameId: string): Promise<TApiResponse<{ game: TGame }>> => {
    return apiClient.patch(`/api/v1/games/${gameId}/abandon`)
  },
  
  // 获取游戏统计
  getGameStats: (gameId: string): Promise<TApiResponse<{ stats: any }>> => {
    return apiClient.get(`/api/v1/games/${gameId}/stats`)
  },
  
  // 获取用户统计
  getUserStats: (): Promise<TApiResponse<{ stats: TStats }>> => {
    return apiClient.get('/api/v1/games/user/stats')
  },
}

// 裁判相关API
export const judgeApi = {
  // 提交问题并获取裁判回答
  judgeQuestion: (gameId: string, question: string): Promise<TApiResponse<{ turn: TTurn, game_status: string }>> => {
    return apiClient.post('/api/v1/judge/', { game_id: gameId, question })
  },
  
  // 批量评分（局后调用）
  batchScore: (gameId: string): Promise<TApiResponse<{ turns: TTurn[], overall_score: number, overall_rationale: string }>> => {
    return apiClient.post(`/api/v1/judge/batch-score?game_id=${gameId}`)
  },
}

// 工具函数
export const apiUtils = {
  // 获取当前用户ID
  getUserId: (): string => {
    return localStorage.getItem('user_id') || ''
  },
  
  // 设置用户ID
  setUserId: (userId: string): void => {
    localStorage.setItem('user_id', userId)
  },
  
  // 清除用户ID
  clearUserId: (): void => {
    localStorage.removeItem('user_id')
  },
}

export default apiClient