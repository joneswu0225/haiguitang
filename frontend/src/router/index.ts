import { createRouter, createWebHistory } from 'vue-router'
import LobbyView from '@/views/LobbyView.vue'
import GamePlayView from '@/views/GamePlayView.vue'
import SoupRevealView from '@/views/SoupRevealView.vue'
import StatsView from '@/views/StatsView.vue'
import AboutView from '@/views/AboutView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'lobby',
      component: LobbyView
    },
    {
      path: '/play/:gameId',
      name: 'play',
      component: GamePlayView,
      props: true
    },
    {
      path: '/review/:gameId',
      name: 'review',
      component: SoupRevealView,
      props: true
    },
    {
      path: '/stats',
      name: 'stats',
      component: StatsView
    },
    {
      path: '/about',
      name: 'about',
      component: AboutView
    }
  ]
})

export default router