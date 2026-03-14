<template>
    <div class="min-h-screen bg-gray-50 font-kanit">
        <!-- Loading -->
        <div v-if="loading" class="flex items-center justify-center min-h-[60vh]">
            <div class="text-center">
                <svg class="animate-spin h-10 w-10 text-blue-600 mx-auto mb-3" xmlns="http://www.w3.org/2000/svg"
                    fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z">
                    </path>
                </svg>
                <p class="text-gray-500 text-sm">กำลังโหลดรีวิว...</p>
            </div>
        </div>

        <!-- Error -->
        <div v-else-if="error" class="flex items-center justify-center min-h-[60vh] px-4">
            <div class="text-center max-w-sm">
                <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <svg class="w-8 h-8 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                    </svg>
                </div>
                <p class="text-gray-700 font-medium">เกิดข้อผิดพลาด</p>
                <p class="text-gray-500 text-sm mt-1">{{ error }}</p>
                <button @click="fetchReviews(1)" class="mt-4 px-4 py-2 bg-blue-600 text-white text-sm rounded-lg hover:bg-blue-700 transition">
                    ลองอีกครั้ง
                </button>
            </div>
        </div>

        <!-- Content -->
        <div v-else class="max-w-2xl mx-auto px-4 py-6">
            <!-- Back Button -->
            <button @click="$router.back()" class="flex items-center gap-1 text-sm text-gray-500 hover:text-gray-700 mb-4 transition">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                </svg>
                ย้อนกลับ
            </button>

            <!-- Driver Header Card -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5 mb-5">
                <div class="flex items-center gap-4">
                    <img
                        :src="driverProfile.profilePicture || `https://ui-avatars.com/api/?name=${encodeURIComponent(driverProfile.fullName)}&background=random&size=128`"
                        :alt="driverProfile.fullName"
                        class="w-16 h-16 rounded-full object-cover border-2 border-blue-100"
                    />
                    <div class="flex-1">
                        <h1 class="text-xl font-semibold text-gray-900">{{ driverProfile.fullName }}</h1>
                        <p class="text-sm text-gray-500">ผู้ใช้งาน</p>
                    </div>
                </div>

                <!-- Rating Summary -->
                <div class="mt-4 flex items-center gap-4 bg-gradient-to-r from-amber-50 to-yellow-50 rounded-lg p-4">
                    <div class="text-center">
                        <p class="text-3xl font-bold text-amber-600">{{ displayAverage }}</p>
                        <div class="flex justify-center mt-0.5">
                            <svg v-for="star in 5" :key="star" class="w-4 h-4"
                                :class="star <= Math.round(averageRating) ? 'text-amber-400' : 'text-gray-300'"
                                fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
                            </svg>
                        </div>
                    </div>
                    <div class="h-10 w-px bg-amber-200"></div>
                    <div>
                        <p class="text-sm text-gray-700">
                            จาก <span class="font-semibold">{{ totalReviews }}</span> รีวิว
                        </p>
                        <p class="text-xs text-gray-500">คะแนนเฉลี่ย {{ displayAverage }} / 5.0</p>
                    </div>
                </div>
            </div>

            <!-- No Reviews -->
            <div v-if="reviews.length === 0" class="bg-white rounded-xl shadow-sm border border-gray-100 p-10 text-center">
                <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                    </svg>
                </div>
                <p class="text-gray-700 font-medium">ยังไม่มีรีวิว</p>
                <p class="text-gray-500 text-sm mt-1">คนขับท่านนี้ยังไม่มีรีวิวจากผู้โดยสาร</p>
            </div>

            <!-- Review List -->
            <div v-else class="space-y-3">
                <div
                    v-for="review in reviews"
                    :key="review.id"
                    class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 hover:shadow-md transition-shadow"
                >
                    <div class="flex items-start gap-3">
                        <img
                            :src="review.passenger?.profilePicture || `https://ui-avatars.com/api/?name=${encodeURIComponent(passengerName(review))}&background=random&size=64`"
                            :alt="passengerName(review)"
                            class="w-10 h-10 rounded-full object-cover border border-gray-200 flex-shrink-0"
                        />
                        <div class="flex-1 min-w-0">
                            <div class="flex items-center justify-between">
                                <p class="font-medium text-gray-900 text-sm truncate">{{ passengerName(review) }}</p>
                                <p class="text-xs text-gray-400 flex-shrink-0 ml-2">{{ formatDate(review.createdAt) }}</p>
                            </div>
                            <!-- Stars -->
                            <div class="flex items-center gap-0.5 mt-0.5">
                                <svg v-for="star in 5" :key="star" class="w-4 h-4"
                                    :class="star <= review.rating ? 'text-amber-400' : 'text-gray-200'"
                                    fill="currentColor" viewBox="0 0 24 24">
                                    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
                                </svg>
                            </div>
                            <!-- Comment -->
                            <p v-if="review.comment" class="mt-2 text-sm text-gray-600 leading-relaxed">{{ review.comment }}</p>

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

                            <!-- Route -->
                            <div v-if="review.booking?.route" class="mt-2 flex items-center gap-1.5 text-xs text-gray-400">
                                <svg class="w-3.5 h-3.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                                </svg>
                                <span class="truncate">{{ review.booking.route.routeSummary || `${review.booking.route.startLocation} → ${review.booking.route.endLocation}` }}</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Pagination -->
                <div v-if="pagination && pagination.totalPages > 1"
                    class="flex items-center justify-center gap-3 pt-4 pb-8">
                    <button
                        :disabled="currentPage <= 1"
                        @click="fetchReviews(currentPage - 1)"
                        class="pagination-btn"
                    >
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                        </svg>
                        ก่อนหน้า
                    </button>
                    <span class="text-sm text-gray-500">
                        หน้า {{ currentPage }} / {{ pagination.totalPages }}
                    </span>
                    <button
                        :disabled="currentPage >= pagination.totalPages"
                        @click="fetchReviews(currentPage + 1)"
                        class="pagination-btn"
                    >
                        ถัดไป
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                        </svg>
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const route = useRoute()
const config = useRuntimeConfig()
const driverId = route.params.driverId

const loading = ref(true)
const error = ref(null)
const reviews = ref([])
const averageRating = ref(0)
const totalReviews = ref(0)
const pagination = ref(null)
const currentPage = ref(1)

// Driver profile — extracted from first review, query param, or kept minimal
const driverProfile = ref({
    fullName: route.query.name || 'คนขับ',
    profilePicture: null,
})

const displayAverage = computed(() => {
    return averageRating.value ? Number(averageRating.value).toFixed(1) : '0.0'
})

function passengerName(review) {
    if (!review.passenger) return 'ผู้โดยสาร'
    return `${review.passenger.firstName} ${review.passenger.lastName}`
}

function formatDate(dateStr) {
    if (!dateStr) return ''
    const date = new Date(dateStr)
    return date.toLocaleDateString('th-TH', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
    })
}

async function fetchReviews(page = 1) {
    loading.value = true
    error.value = null
    try {
        // Use raw $fetch to avoid $api auto-unwrap (we need averageRating, totalReviews, pagination)
        const res = await $fetch(`/reviews/driver/${driverId}`, {
            baseURL: config.public.apiBase,
            params: { page, limit: 20 },
        })

        reviews.value = res.data || []
        averageRating.value = res.averageRating || 0
        totalReviews.value = res.totalReviews || 0
        pagination.value = res.pagination || null
        currentPage.value = page

        // Extract driver info from first review if available
        if (reviews.value.length > 0) {
            const firstReview = reviews.value[0]
            const d = firstReview.booking?.route?.driver
            if (d) {
                driverProfile.value = {
                    fullName: `${d.firstName} ${d.lastName}`,
                    profilePicture: d.profilePicture,
                }
            }
        }

        // If still no driver profile, try fetching user profile directly
        if (driverProfile.value.fullName === 'คนขับ') {
            try {
                const user = await $fetch(`/users/${driverId}`, { baseURL: config.public.apiBase })
                if (user) {
                    driverProfile.value = {
                        fullName: `${user.firstName || ''} ${user.lastName || ''}`.trim() || 'คนขับ',
                        profilePicture: user.profilePicture || null,
                    }
                }
            } catch { /* ignore - use default */ }
        }
    } catch (err) {
        error.value = err?.data?.message || err?.statusMessage || 'ไม่สามารถโหลดรีวิวได้'
    } finally {
        loading.value = false
    }
}

onMounted(() => {
    fetchReviews(1)
})
</script>

<style scoped>
.font-kanit {
    font-family: 'Kanit', sans-serif;
}

.pagination-btn {
    display: flex;
    align-items: center;
    gap: 0.25rem;
    padding: 0.5rem 1rem;
    border-radius: 0.5rem;
    font-size: 0.875rem;
    font-weight: 500;
    color: #374151;
    background-color: white;
    border: 1px solid #d1d5db;
    transition: all 0.2s;
    font-family: 'Kanit', sans-serif;
    cursor: pointer;
}

.pagination-btn:hover:not(:disabled) {
    background-color: #f3f4f6;
    border-color: #9ca3af;
}

.pagination-btn:disabled {
    opacity: 0.4;
    cursor: not-allowed;
}
</style>
