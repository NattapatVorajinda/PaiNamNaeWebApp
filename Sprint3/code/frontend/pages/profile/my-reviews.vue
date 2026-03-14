<template>
    <div>
        <div class="flex items-center justify-center min-h-screen py-8">
            <div
                class="flex w-full max-w-6xl mx-4 overflow-hidden bg-white border border-gray-300 rounded-lg shadow-lg">

                <ProfileSidebar />

                <main class="flex-1 p-8">
                    <div>
                        <div class="mb-8 text-center">
                            <div
                                class="inline-flex items-center justify-center w-16 h-16 mb-4 bg-amber-500 rounded-full">
                                <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z">
                                    </path>
                                </svg>
                            </div>
                            <h1 class="mb-2 text-3xl font-bold text-gray-800">เช็ครีวิวของตัวเอง</h1>
                            <p class="max-w-md mx-auto text-gray-600">
                                ดูรีวิวทั้งหมดที่ผู้โดยสารเขียนให้คุณ
                            </p>
                        </div>

                        <!-- Summary -->
                        <div v-if="!isLoading && reviews.length > 0"
                            class="flex items-center justify-center gap-6 p-4 mb-6 border border-amber-200 rounded-lg bg-amber-50">
                            <div class="text-center">
                                <p class="text-2xl font-bold text-amber-600">{{ averageRating }}</p>
                                <p class="text-xs text-gray-500">คะแนนเฉลี่ย</p>
                            </div>
                            <div class="w-px h-8 bg-amber-200"></div>
                            <div class="text-center">
                                <p class="text-2xl font-bold text-amber-600">{{ totalReviews }}</p>
                                <p class="text-xs text-gray-500">รีวิวทั้งหมด</p>
                            </div>
                        </div>

                        <!-- Loading -->
                        <div v-if="isLoading" class="py-12 text-center text-gray-500">
                            <svg class="w-8 h-8 mx-auto mb-3 text-blue-500 animate-spin" fill="none"
                                viewBox="0 0 24 24">
                                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor"
                                    stroke-width="4" />
                                <path class="opacity-75" fill="currentColor"
                                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                            </svg>
                            <p>กำลังโหลดรีวิว...</p>
                        </div>

                        <!-- Empty state -->
                        <div v-else-if="reviews.length === 0" class="py-16 text-center">
                            <svg class="w-16 h-16 mx-auto mb-4 text-gray-300" fill="none" stroke="currentColor"
                                viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                                    d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                            </svg>
                            <h3 class="mb-2 text-lg font-semibold text-gray-700">ยังไม่มีรีวิว</h3>
                            <p class="text-sm text-gray-500">เมื่อมีผู้เขียนรีวิวให้คุณ รีวิวจะแสดงที่นี่</p>
                        </div>

                        <!-- Review list -->
                        <div v-else class="space-y-4">
                            <div v-for="review in reviews" :key="review.id"
                                class="p-5 transition-shadow bg-white border border-gray-200 rounded-lg hover:shadow-md">

                                <!-- Reviewer (passenger) info + date -->
                                <div class="flex items-start justify-between mb-3">
                                    <div class="flex items-center gap-3">
                                        <img :src="personAvatar(review.passenger)"
                                            :alt="personName(review.passenger)"
                                            class="object-cover w-10 h-10 border-2 border-gray-100 rounded-full" />
                                        <div>
                                            <p class="text-sm font-semibold text-gray-900">{{
                                                personName(review.passenger) }}</p>
                                            <p class="text-xs text-gray-500">ผู้โดยสาร</p>
                                        </div>
                                    </div>
                                    <span class="text-xs text-gray-400">{{ formatDate(review.createdAt) }}</span>
                                </div>

                                <!-- Route info -->
                                <div v-if="review.booking?.route"
                                    class="flex items-center gap-2 px-3 py-2 mb-3 text-sm rounded-md bg-gray-50">
                                    <svg class="w-4 h-4 text-gray-400 shrink-0" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                                    </svg>
                                    <span class="text-gray-700">{{ routeLabel(review.booking.route) }}</span>
                                </div>

                                <!-- Stars -->
                                <div class="flex items-center gap-2 mb-2">
                                    <div class="flex">
                                        <span v-for="star in 5" :key="star" class="text-lg"
                                            :class="star <= review.rating ? 'text-yellow-400' : 'text-gray-300'">★</span>
                                    </div>
                                    <span class="text-sm font-medium text-gray-600">{{ review.rating }}/5</span>
                                </div>

                                <!-- Comment -->
                                <p v-if="review.comment" class="text-sm leading-relaxed text-gray-700">{{
                                    review.comment }}</p>
                                <p v-else class="text-sm italic text-gray-400">ไม่มีความคิดเห็น</p>

                                <!-- Media Attachments -->
                                <div v-if="review.mediaUrls && review.mediaUrls.length > 0" class="mt-3">
                                    <div class="flex flex-wrap gap-2">
                                        <template v-for="(media, mIdx) in review.mediaUrls" :key="mIdx">
                                            <!-- Image -->
                                            <a v-if="media.type === 'image'" :href="media.url" target="_blank" rel="noopener">
                                                <img :src="media.url" :alt="media.originalName || 'หลักฐาน'"
                                                    class="w-20 h-20 rounded-lg object-cover border border-gray-200 hover:opacity-80 transition cursor-pointer" />
                                            </a>
                                            <!-- Audio -->
                                            <div v-else-if="media.type === 'audio'" class="w-full">
                                                <audio controls class="w-full h-8" style="max-width: 280px;">
                                                    <source :src="media.url">
                                                </audio>
                                            </div>
                                            <!-- Video -->
                                            <div v-else-if="media.type === 'video'" class="w-full">
                                                <video controls class="w-full rounded-lg" style="max-width: 280px; max-height: 180px;">
                                                    <source :src="media.url">
                                                </video>
                                            </div>
                                        </template>
                                    </div>
                                </div>
                            </div>

                            <!-- Pagination -->
                            <div v-if="pagination.totalPages > 1"
                                class="flex items-center justify-center gap-2 pt-4">
                                <button @click="goToPage(pagination.page - 1)" :disabled="pagination.page <= 1"
                                    class="px-3 py-1.5 text-sm border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed">
                                    ← ก่อนหน้า
                                </button>
                                <span class="px-3 py-1.5 text-sm text-gray-600">
                                    หน้า {{ pagination.page }} / {{ pagination.totalPages }}
                                </span>
                                <button @click="goToPage(pagination.page + 1)"
                                    :disabled="pagination.page >= pagination.totalPages"
                                    class="px-3 py-1.5 text-sm border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed">
                                    ถัดไป →
                                </button>
                            </div>
                        </div>
                    </div>
                </main>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import ProfileSidebar from '~/components/ProfileSidebar.vue'
import dayjs from 'dayjs'
import 'dayjs/locale/th'
import buddhistEra from 'dayjs/plugin/buddhistEra'

dayjs.locale('th')
dayjs.extend(buddhistEra)

definePageMeta({ middleware: 'auth' })

const isLoading = ref(false)
const reviews = ref([])
const averageRating = ref(0)
const totalReviews = ref(0)
const pagination = ref({ page: 1, limit: 10, total: 0, totalPages: 0 })

async function fetchReviews(page = 1) {
    isLoading.value = true
    try {
        const config = useRuntimeConfig()
        const token = useCookie('token').value
        const res = await $fetch(`/reviews/me?page=${page}&limit=10`, {
            baseURL: config.public.apiBase,
            headers: token ? { Authorization: `Bearer ${token}` } : {},
        })
        reviews.value = res.data || []
        averageRating.value = res.averageRating || 0
        totalReviews.value = res.totalReviews || 0
        pagination.value = res.pagination || { page: 1, limit: 10, total: 0, totalPages: 0 }
    } catch (e) {
        console.error('Failed to fetch my reviews:', e)
        reviews.value = []
    } finally {
        isLoading.value = false
    }
}

function goToPage(page) {
    if (page < 1 || page > pagination.value.totalPages) return
    fetchReviews(page)
}

function personName(person) {
    if (!person) return 'ไม่ทราบ'
    return `${person.firstName || ''} ${person.lastName || ''}`.trim() || 'ไม่ทราบ'
}

function personAvatar(person) {
    if (person?.profilePicture) return person.profilePicture
    return `https://ui-avatars.com/api/?name=${encodeURIComponent(personName(person))}&background=random&size=64`
}

function routeLabel(route) {
    if (!route) return '-'
    const start = typeof route.startLocation === 'object' ? (route.startLocation?.name || '') : route.startLocation
    const end = typeof route.endLocation === 'object' ? (route.endLocation?.name || '') : route.endLocation
    if (start && end) return `${start} → ${end}`
    return route.routeSummary || '-'
}

function formatDate(dateStr) {
    if (!dateStr) return ''
    return dayjs(dateStr).format('D MMM BBBB HH:mm')
}

onMounted(() => {
    fetchReviews()
})
</script>

<style scoped>
/* Scoped styles can be added here if needed */
</style>
