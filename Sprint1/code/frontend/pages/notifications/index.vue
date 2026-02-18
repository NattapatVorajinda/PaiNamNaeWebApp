<template>
    <div>
        <div class="px-4 py-8 mx-auto max-w-7xl sm:px-6 lg:px-8">
            <div class="mb-8">
                <h2 class="text-2xl font-bold text-gray-900">การแจ้งเตือน</h2>
                <p class="mt-2 text-gray-600">ดูและจัดการการแจ้งเตือนทั้งหมดของคุณ</p>
            </div>

            <!-- Tabs + Actions -->
            <div class="p-6 mb-8 bg-white border border-gray-300 rounded-lg shadow-md">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div class="flex flex-wrap gap-2">
                        <button @click="activeTab = 'all'"
                            :class="['tab-button px-4 py-2 rounded-md font-medium', { 'active': activeTab === 'all' }]">
                            ทั้งหมด ({{ notifications.length }})
                        </button>
                        <button @click="activeTab = 'unread'"
                            :class="['tab-button px-4 py-2 rounded-md font-medium', { 'active': activeTab === 'unread' }]">
                            ยังไม่อ่าน ({{ unreadCount }})
                        </button>
                        <button @click="activeTab = 'read'"
                            :class="['tab-button px-4 py-2 rounded-md font-medium', { 'active': activeTab === 'read' }]">
                            อ่านแล้ว ({{ readCount }})
                        </button>
                    </div>
                    <button v-if="unreadCount > 0" @click="markAllAsRead"
                        class="px-4 py-2 text-sm font-medium text-blue-600 bg-blue-50 border border-blue-200 rounded-md hover:bg-blue-100 transition-colors">
                        อ่านทั้งหมด
                    </button>
                </div>
            </div>

            <!-- Loading -->
            <div v-if="loading" class="bg-white border border-gray-300 rounded-lg shadow-md">
                <div class="p-12 text-center text-gray-500">
                    <p>กำลังโหลดการแจ้งเตือน...</p>
                </div>
            </div>

            <!-- Empty -->
            <div v-else-if="filteredNotifications.length === 0"
                class="bg-white border border-gray-300 rounded-lg shadow-md">
                <div class="p-12 text-center">
                    <svg class="w-16 h-16 mx-auto mb-4 text-gray-300" fill="none" viewBox="0 0 24 24"
                        stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                            d="M15 17h5l-1.405-1.405C18.21 14.79 18 13.918 18 13V9a6 6 0 10-12 0v4c0 .918-.21 1.79-.595 2.595L4 17h5m6 0a3 3 0 11-6 0h6z" />
                    </svg>
                    <p class="text-gray-500 text-lg font-medium">ไม่มีการแจ้งเตือน</p>
                    <p class="mt-1 text-sm text-gray-400">
                        {{ activeTab === 'unread' ? 'ไม่มีการแจ้งเตือนที่ยังไม่ได้อ่าน' : activeTab === 'read' ?
                            'ไม่มีการแจ้งเตือนที่อ่านแล้ว' : 'คุณยังไม่มีการแจ้งเตือนใดๆ' }}
                    </p>
                </div>
            </div>

            <!-- Notification List -->
            <div v-else class="bg-white border border-gray-300 rounded-lg shadow-md">
                <div class="p-6 border-b border-gray-300">
                    <h3 class="text-lg font-semibold text-gray-900">รายการแจ้งเตือน</h3>
                </div>
                <div class="divide-y divide-gray-200">
                    <div v-for="n in filteredNotifications" :key="n.id"
                        class="p-6 transition-colors duration-200 hover:bg-gray-50"
                        :class="{ 'bg-blue-50/50': !n.readAt }">
                        <div class="flex items-start gap-4">
                            <!-- Icon -->
                            <div class="shrink-0 mt-0.5">
                                <div class="flex items-center justify-center w-10 h-10 rounded-full"
                                    :class="n.readAt ? 'bg-gray-100' : 'bg-blue-100'">
                                    <svg class="w-5 h-5" :class="n.readAt ? 'text-gray-400' : 'text-blue-600'"
                                        fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M15 17h5l-1.405-1.405C18.21 14.79 18 13.918 18 13V9a6 6 0 10-12 0v4c0 .918-.21 1.79-.595 2.595L4 17h5m6 0a3 3 0 11-6 0h6z" />
                                    </svg>
                                </div>
                            </div>

                            <!-- Content -->
                            <div class="flex-1 min-w-0">
                                <div class="flex items-center gap-2">
                                    <p class="text-base font-semibold text-gray-900">{{ n.title }}</p>
                                    <span v-if="!n.readAt"
                                        class="inline-block w-2 h-2 rounded-full bg-blue-500 shrink-0"></span>
                                </div>
                                <p class="mt-1 text-sm text-gray-600">{{ n.body }}</p>
                                <p class="mt-2 text-xs text-gray-400">{{ formatDate(n.createdAt) }}</p>
                            </div>

                            <!-- Actions -->
                            <div class="flex items-center gap-1 shrink-0">
                                <button v-if="!n.readAt" @click="markAsRead(n)"
                                    class="px-3 py-1.5 text-xs font-medium text-blue-600 bg-blue-50 border border-blue-200 rounded-md hover:bg-blue-100 transition-colors"
                                    title="ทำเครื่องหมายอ่านแล้ว">
                                    อ่านแล้ว
                                </button>
                                <button @click="deleteNotification(n)"
                                    class="px-3 py-1.5 text-xs font-medium text-red-600 bg-red-50 border border-red-200 rounded-md hover:bg-red-100 transition-colors"
                                    title="ลบการแจ้งเตือน">
                                    ลบ
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRuntimeConfig, useCookie } from '#app'
import { useToast } from '~/composables/useToast'

definePageMeta({ middleware: 'auth' })

useHead({
    title: 'การแจ้งเตือน - ไปนำแหน่',
})

const { $api } = useNuxtApp()
const { toast } = useToast()

const loading = ref(true)
const notifications = ref([])
const activeTab = ref('all')

const apiBase = useRuntimeConfig().public.apiBase || 'http://localhost:3000/api'

function getToken() {
    return useCookie('token')?.value || (process.client ? localStorage.getItem('token') : '')
}

function authHeaders() {
    const tk = getToken()
    return { Accept: 'application/json', ...(tk ? { Authorization: `Bearer ${tk}` } : {}) }
}

const unreadCount = computed(() => notifications.value.filter(n => !n.readAt).length)
const readCount = computed(() => notifications.value.filter(n => n.readAt).length)

const filteredNotifications = computed(() => {
    if (activeTab.value === 'unread') return notifications.value.filter(n => !n.readAt)
    if (activeTab.value === 'read') return notifications.value.filter(n => n.readAt)
    return notifications.value
})

async function fetchNotifications() {
    try {
        loading.value = true
        const res = await $fetch('/notifications', {
            baseURL: apiBase,
            headers: authHeaders(),
            query: { page: 1, limit: 50 }
        })
        const raw = Array.isArray(res?.data) ? res.data : (Array.isArray(res) ? res : [])
        notifications.value = raw.map(it => ({
            id: it.id,
            title: it.title || '-',
            body: it.body || '',
            createdAt: it.createdAt || Date.now(),
            readAt: it.readAt || null
        }))
    } catch (e) {
        console.error('Failed to fetch notifications:', e)
    } finally {
        loading.value = false
    }
}

async function markAsRead(n) {
    try {
        await $fetch(`/notifications/${n.id}/read`, {
            baseURL: apiBase,
            method: 'PATCH',
            headers: authHeaders(),
        })
        const i = notifications.value.findIndex(x => x.id === n.id)
        if (i > -1) notifications.value[i].readAt = new Date().toISOString()
    } catch (e) {
        console.error(e)
        toast.error('เกิดข้อผิดพลาด', 'ไม่สามารถทำเครื่องหมายอ่านแล้วได้')
    }
}

async function markAllAsRead() {
    try {
        await $fetch('/notifications/read-all', {
            baseURL: apiBase,
            method: 'PATCH',
            headers: authHeaders(),
        })
        notifications.value.forEach(n => {
            if (!n.readAt) n.readAt = new Date().toISOString()
        })
        toast.success('สำเร็จ', 'ทำเครื่องหมายอ่านทั้งหมดแล้ว')
    } catch (e) {
        console.error(e)
        toast.error('เกิดข้อผิดพลาด', 'ไม่สามารถทำเครื่องหมายอ่านทั้งหมดได้')
    }
}

async function deleteNotification(n) {
    try {
        await $fetch(`/notifications/${n.id}`, {
            baseURL: apiBase,
            method: 'DELETE',
            headers: authHeaders(),
        })
        notifications.value = notifications.value.filter(x => x.id !== n.id)
        toast.success('ลบสำเร็จ', 'ลบการแจ้งเตือนออกแล้ว')
    } catch (e) {
        console.error(e)
        toast.error('เกิดข้อผิดพลาด', 'ไม่สามารถลบการแจ้งเตือนได้')
    }
}

function formatDate(ts) {
    const d = new Date(ts)
    const now = new Date()
    const diffMs = now - d
    const diffMin = Math.floor(diffMs / 60000)

    if (diffMin < 1) return 'เมื่อสักครู่'
    if (diffMin < 60) return `${diffMin} นาทีที่แล้ว`
    const diffHr = Math.floor(diffMin / 60)
    if (diffHr < 24) return `${diffHr} ชั่วโมงที่แล้ว`
    const diffDay = Math.floor(diffHr / 24)
    if (diffDay < 7) return `${diffDay} วันที่แล้ว`

    return d.toLocaleDateString('th-TH', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}

onMounted(() => {
    fetchNotifications()
})
</script>

<style scoped>
.tab-button {
    transition: all 0.3s ease;
}

.tab-button.active {
    background-color: #3b82f6;
    color: white;
    box-shadow: 0 4px 14px rgba(59, 130, 246, 0.3);
}

.tab-button:not(.active) {
    background-color: white;
    color: #6b7280;
    border: 1px solid #d1d5db;
}

.tab-button:not(.active):hover {
    background-color: #f9fafb;
    color: #374151;
}
</style>
