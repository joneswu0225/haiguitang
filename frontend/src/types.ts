export type TGameStatus = 'active' | 'completed' | 'abandoned'
export type TJudgeAnswer = 'yes' | 'no' | 'irrelevant'

export interface TGame {
  id: string
  user_id: string
  soup_id: string
  status: TGameStatus
  started_at: string
  ended_at?: string
  turns: TTurn[]
  proximity_score?: number
  proximity_rationale?: string
}

export interface TTurn {
  id: string
  game_id: string
  question: string
  answer: TJudgeAnswer
  created_at: string
  proximity_score?: number
  proximity_rationale?: string
}

export interface TSoup {
  id: string
  title: string
  surface: string
  bottom: string
  key_facts: string[]
  difficulty: '简单' | '中等' | '困难'
  category: string
  estimatedTime: string
  playedCount: number
  soup_version?: string
}

export interface TStats {
  completedGames: number
  averageTime: string
  successRate: number
  totalQuestions: number
}

export interface TApiResponse<T = any> {
  data: T
  message?: string
  error?: string
}

export interface TCreateGameRequest {
  soup_id: string
  user_id: string
}

export interface TSubmitTurnRequest {
  game_id: string
  question: string
}

export interface TSubmitTurnResponse {
  turn: TTurn
  game_status: TGameStatus
}

export interface TCompleteGameRequest {
  game_id: string
  user_id: string
}

export interface TAbandonGameRequest {
  game_id: string
  user_id: string
}

export interface TProximityScore {
  turn_id: string
  score: number
  rationale: string
}