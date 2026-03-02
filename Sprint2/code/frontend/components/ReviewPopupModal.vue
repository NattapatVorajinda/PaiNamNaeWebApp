<template>
    <transition name="modal-fade">
        <div v-if="show" class="modal-overlay" @click.self="handleSkip">
            <div class="modal-content font-kanit">
                <!-- Header -->
                <div class="p-5 pb-3 text-center border-b border-gray-100">
                    <h3 class="text-lg font-semibold text-gray-900">ให้คะแนนการเดินทาง</h3>
                    <p class="mt-1 text-sm text-gray-500">บอกเราว่าการเดินทางครั้งนี้เป็นอย่างไร</p>
                </div>

                <!-- Driver Info -->
                <div v-if="booking" class="px-5 pt-4 pb-2">
                    <div class="flex items-center gap-3 mb-3">
                        <img
                            :src="driverInfo.profilePicture || `https://ui-avatars.com/api/?name=${encodeURIComponent(driverInfo.fullName)}&background=random&size=96`"
                            :alt="driverInfo.fullName"
                            class="w-12 h-12 rounded-full object-cover border-2 border-blue-100"
                        />
                        <div class="text-left">
                            <p class="font-medium text-gray-900">{{ driverInfo.fullName }}</p>
                            <p class="text-xs text-gray-500">คนขับ</p>
                        </div>
                    </div>
                    <!-- Route Info -->
                    <div class="bg-gray-50 rounded-lg p-3 text-sm text-left">
                        <div class="flex items-start gap-2">
                            <div class="flex flex-col items-center mt-0.5">
                                <span class="w-2.5 h-2.5 rounded-full bg-green-500"></span>
                                <span class="w-0.5 h-6 bg-gray-300"></span>
                                <span class="w-2.5 h-2.5 rounded-full bg-red-500"></span>
                            </div>
                            <div class="flex-1 space-y-2">
                                <p class="text-gray-700 truncate">{{ routeInfo.startLocation }}</p>
                                <p class="text-gray-700 truncate">{{ routeInfo.endLocation }}</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Star Rating -->
                <div class="px-5 py-3 text-center">
                    <p class="text-sm font-medium text-gray-700 mb-2">ให้คะแนน</p>
                    <div class="flex justify-center gap-1.5">
                        <button
                            v-for="star in 5"
                            :key="star"
                            type="button"
                            class="star-btn"
                            :class="{ active: star <= selectedRating, hover: star <= hoverRating && hoverRating > 0 }"
                            @mouseenter="hoverRating = star"
                            @mouseleave="hoverRating = 0"
                            @click="selectedRating = star"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" class="w-9 h-9" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
                            </svg>
                        </button>
                    </div>
                    <p class="text-xs text-gray-400 mt-1.5">{{ ratingLabel }}</p>
                </div>

                <!-- Comment -->
                <div class="px-5 pb-3">
                    <label class="block text-sm font-medium text-gray-700 text-left mb-1">
                        ความคิดเห็น <span class="text-gray-400 font-normal">(ไม่บังคับ)</span>
                    </label>
                    <textarea
                        v-model="comment"
                        maxlength="500"
                        rows="3"
                        class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-none font-kanit"
                        placeholder="เล่าประสบการณ์ของคุณ..."
                    ></textarea>
                    <p class="text-xs text-gray-400 text-right mt-0.5">{{ comment.length }}/500</p>
                </div>

                <!-- Actions -->
                <div class="bg-gray-50 px-5 py-4 flex justify-end gap-3 rounded-b-xl">
                    <button
                        type="button"
                        class="btn-secondary"
                        :disabled="submitting"
                        @click="handleSkip"
                    >
                        ข้ามไปก่อน
                    </button>
                    <button
                        type="button"
                        class="btn-submit"
                        :disabled="selectedRating === 0 || submitting"
                        @click="handleSubmit"
                    >
                        <svg v-if="submitting" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white inline" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                        </svg>
                        {{ submitting ? 'กำลังส่ง...' : 'ส่งรีวิว' }}
                    </button>
                </div>
            </div>
        </div>
    </transition>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
    show: {
        type: Boolean,
        required: true,
    },
    booking: {
        type: Object,
        default: null,
    },
})

const emit = defineEmits(['submitted', 'skip'])

const { $api } = useNuxtApp()
const { toast } = useToast()

const selectedRating = ref(0)
const hoverRating = ref(0)
const comment = ref('')
const submitting = ref(false)

const RATING_LABELS = ['', 'แย่มาก', 'ไม่ดี', 'พอใช้', 'ดี', 'ยอดเยี่ยม']

const ratingLabel = computed(() => {
    const active = hoverRating.value || selectedRating.value
    return RATING_LABELS[active] || 'แตะดาวเพื่อให้คะแนน'
})

const driverInfo = computed(() => {
    const driver = props.booking?.route?.driver
    return {
        fullName: driver ? `${driver.firstName} ${driver.lastName}` : '',
        profilePicture: driver?.profilePicture || null,
    }
})

const routeInfo = computed(() => {
    const route = props.booking?.route
    const start = route?.startLocation
    const end = route?.endLocation
    return {
        startLocation: (typeof start === 'object' && start !== null) ? (start.name || `${Number(start.lat).toFixed(4)}, ${Number(start.lng).toFixed(4)}`) : (start || '-'),
        endLocation: (typeof end === 'object' && end !== null) ? (end.name || `${Number(end.lat).toFixed(4)}, ${Number(end.lng).toFixed(4)}`) : (end || '-'),
    }
})

/* ---- sessionStorage helpers ---- */
function getReviewedIds() {
    try {
        return JSON.parse(sessionStorage.getItem('reviewed_bookings') || '[]')
    } catch {
        return []
    }
}

function markAsReviewed(bookingId) {
    const ids = getReviewedIds()
    if (!ids.includes(bookingId)) {
        ids.push(bookingId)
        sessionStorage.setItem('reviewed_bookings', JSON.stringify(ids))
    }
}

/* ---- actions ---- */
async function handleSubmit() {
    if (!props.booking || selectedRating.value === 0) return

    submitting.value = true
    try {
        await $api('/reviews', {
            method: 'POST',
            body: {
                bookingId: props.booking.id,
                rating: selectedRating.value,
                comment: comment.value.trim() || undefined,
            },
        })
        markAsReviewed(props.booking.id)
        toast.success('สำเร็จ', 'ส่งรีวิวเรียบร้อยแล้ว')
        resetForm()
        emit('submitted')
    } catch (err) {
        toast.error('เกิดข้อผิดพลาด', err?.statusMessage || 'ไม่สามารถส่งรีวิวได้')
    } finally {
        submitting.value = false
    }
}

function handleSkip() {
    if (props.booking) {
        markAsReviewed(props.booking.id)
    }
    resetForm()
    emit('skip')
}

function resetForm() {
    selectedRating.value = 0
    hoverRating.value = 0
    comment.value = ''
}
</script>

<style scoped>
.font-kanit {
    font-family: 'Kanit', sans-serif;
}

.modal-overlay {
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
}

.modal-content {
    background-color: white;
    border-radius: 0.75rem;
    max-width: 420px;
    width: 92%;
    box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
    transform: scale(1);
    overflow: hidden;
}

/* Stars */
.star-btn {
    color: #d1d5db;
    transition: color 0.15s ease, transform 0.15s ease;
    cursor: pointer;
    background: none;
    border: none;
    padding: 2px;
}

.star-btn:hover {
    transform: scale(1.15);
}

.star-btn.active,
.star-btn.hover {
    color: #facc15;
}

/* Buttons */
.btn-secondary {
    padding: 0.5rem 1.25rem;
    border-radius: 0.5rem;
    font-weight: 500;
    font-size: 0.875rem;
    color: #374151;
    background-color: white;
    border: 1px solid #d1d5db;
    transition: all 0.2s;
    font-family: 'Kanit', sans-serif;
    cursor: pointer;
}

.btn-secondary:hover {
    background-color: #f9fafb;
}

.btn-submit {
    padding: 0.5rem 1.5rem;
    border-radius: 0.5rem;
    font-weight: 500;
    font-size: 0.875rem;
    color: white;
    background-color: #2563eb;
    border: 1px solid transparent;
    transition: all 0.2s;
    font-family: 'Kanit', sans-serif;
    cursor: pointer;
}

.btn-submit:hover:not(:disabled) {
    background-color: #1d4ed8;
}

.btn-submit:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

/* Transitions */
.modal-fade-enter-active,
.modal-fade-leave-active {
    transition: opacity 0.3s ease;
}

.modal-fade-enter-active .modal-content,
.modal-fade-leave-active .modal-content {
    transition: all 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
    opacity: 0;
}

.modal-fade-enter-from .modal-content,
.modal-fade-leave-to .modal-content {
    transform: scale(0.95) translateY(1rem);
}
</style>
