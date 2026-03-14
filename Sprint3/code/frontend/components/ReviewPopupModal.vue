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

                <!-- Media Attachments -->
                <div class="px-5 pb-3">
                    <label class="block text-sm font-medium text-gray-700 text-left mb-2">
                        แนบหลักฐาน <span class="text-gray-400 font-normal">(ไม่บังคับ — ภาพ, เสียง, วิดีโอ สูงสุด 5 ไฟล์)</span>
                    </label>

                    <!-- Attach Button -->
                    <button
                        v-if="mediaFiles.length < 5"
                        type="button"
                        class="attach-btn"
                        @click="$refs.fileInput.click()"
                    >
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.414a4 4 0 00-5.656-5.656l-6.415 6.414a6 6 0 108.486 8.486L20.5 13" />
                        </svg>
                        แนบไฟล์
                    </button>
                    <input
                        ref="fileInput"
                        type="file"
                        accept="image/*,audio/*,video/*"
                        multiple
                        class="hidden"
                        @change="handleFileSelect"
                    />

                    <!-- File Previews -->
                    <div v-if="mediaFiles.length > 0" class="mt-2 space-y-2">
                        <div
                            v-for="(file, index) in mediaFiles"
                            :key="index"
                            class="file-preview"
                        >
                            <!-- Image preview -->
                            <img
                                v-if="file.type.startsWith('image/')"
                                :src="file.preview"
                                class="w-12 h-12 rounded-md object-cover flex-shrink-0"
                            />
                            <!-- Audio icon -->
                            <div v-else-if="file.type.startsWith('audio/')" class="w-12 h-12 rounded-md bg-purple-100 flex items-center justify-center flex-shrink-0">
                                <svg class="w-6 h-6 text-purple-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
                                </svg>
                            </div>
                            <!-- Video icon -->
                            <div v-else-if="file.type.startsWith('video/')" class="w-12 h-12 rounded-md bg-blue-100 flex items-center justify-center flex-shrink-0">
                                <svg class="w-6 h-6 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
                                </svg>
                            </div>

                            <div class="flex-1 min-w-0 ml-3">
                                <p class="text-sm text-gray-700 truncate">{{ file.name }}</p>
                                <p class="text-xs text-gray-400">{{ formatFileSize(file.size) }}</p>
                            </div>

                            <button type="button" class="remove-file-btn" @click="removeFile(index)">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                                </svg>
                            </button>
                        </div>
                    </div>
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

const config = useRuntimeConfig()
const { toast } = useToast()

const selectedRating = ref(0)
const hoverRating = ref(0)
const comment = ref('')
const submitting = ref(false)
const mediaFiles = ref([])
const fileInput = ref(null)

const RATING_LABELS = ['', 'แย่มาก', 'ไม่ดี', 'พอใช้', 'ดี', 'ยอดเยี่ยม']
const MAX_FILES = 5
const MAX_FILE_SIZE = 50 * 1024 * 1024 // 50 MB

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

/* ---- File handling ---- */
function handleFileSelect(event) {
    const files = Array.from(event.target.files)
    const remaining = MAX_FILES - mediaFiles.value.length

    if (files.length > remaining) {
        toast.error('ข้อจำกัด', `แนบได้สูงสุด ${MAX_FILES} ไฟล์`)
    }

    const filesToAdd = files.slice(0, remaining)

    for (const file of filesToAdd) {
        if (file.size > MAX_FILE_SIZE) {
            toast.error('ไฟล์ใหญ่เกินไป', `${file.name} มีขนาดเกิน 50 MB`)
            continue
        }

        const fileObj = {
            file,
            name: file.name,
            size: file.size,
            type: file.type,
            preview: null,
        }

        // Generate image preview
        if (file.type.startsWith('image/')) {
            const reader = new FileReader()
            reader.onload = (e) => {
                fileObj.preview = e.target.result
            }
            reader.readAsDataURL(file)
        }

        mediaFiles.value.push(fileObj)
    }

    // Reset input so the same file can be selected again
    event.target.value = ''
}

function removeFile(index) {
    mediaFiles.value.splice(index, 1)
}

function formatFileSize(bytes) {
    if (bytes < 1024) return `${bytes} B`
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

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
        const token = useCookie('token').value

        // Build FormData for multipart upload
        const formData = new FormData()
        formData.append('bookingId', props.booking.id)
        formData.append('rating', selectedRating.value.toString())
        if (comment.value.trim()) {
            formData.append('comment', comment.value.trim())
        }

        // Append media files
        for (const item of mediaFiles.value) {
            formData.append('media', item.file)
        }

        await $fetch('/reviews', {
            baseURL: config.public.apiBase,
            method: 'POST',
            body: formData,
            headers: token ? { Authorization: `Bearer ${token}` } : {},
        })

        markAsReviewed(props.booking.id)
        toast.success('สำเร็จ', 'ส่งรีวิวเรียบร้อยแล้ว')
        resetForm()
        emit('submitted')
    } catch (err) {
        toast.error('เกิดข้อผิดพลาด', err?.data?.message || err?.statusMessage || 'ไม่สามารถส่งรีวิวได้')
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
    mediaFiles.value = []
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
    overflow-y: auto;
    max-height: 90vh;
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

/* Attach Button */
.attach-btn {
    display: inline-flex;
    align-items: center;
    gap: 0.375rem;
    padding: 0.5rem 0.875rem;
    border-radius: 0.5rem;
    font-size: 0.8125rem;
    font-weight: 500;
    color: #4b5563;
    background-color: #f3f4f6;
    border: 1px dashed #d1d5db;
    transition: all 0.2s;
    font-family: 'Kanit', sans-serif;
    cursor: pointer;
}

.attach-btn:hover {
    background-color: #e5e7eb;
    border-color: #9ca3af;
}

/* File Preview */
.file-preview {
    display: flex;
    align-items: center;
    padding: 0.5rem;
    border-radius: 0.5rem;
    background-color: #f9fafb;
    border: 1px solid #e5e7eb;
}

.remove-file-btn {
    padding: 0.25rem;
    color: #9ca3af;
    background: none;
    border: none;
    cursor: pointer;
    border-radius: 0.375rem;
    transition: all 0.15s;
    flex-shrink: 0;
}

.remove-file-btn:hover {
    color: #ef4444;
    background-color: #fee2e2;
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
