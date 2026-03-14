<template>
    <div class="min-h-screen bg-gray-50 font-kanit">
        <div class="max-w-lg mx-auto px-4 py-8">
            <!-- Header -->
            <div class="mb-6">
                <NuxtLink to="/profile" class="text-sm text-blue-600 hover:underline flex items-center gap-1 mb-2">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                    </svg>
                    กลับไปโปรไฟล์
                </NuxtLink>
                <h1 class="text-2xl font-bold text-gray-900">ตั้งค่าพร้อมเพย์</h1>
                <p class="text-sm text-gray-500 mt-1">ตั้งค่าบัญชีรับเงินสำหรับผู้โดยสารโอนค่าโดยสาร</p>
            </div>

            <!-- Current PromptPay Info -->
            <div v-if="currentData.promptPayNumber || currentData.promptPayQrUrl" class="bg-white rounded-xl p-5 shadow-sm mb-6 border border-gray-100">
                <h2 class="text-sm font-semibold text-gray-700 mb-3">ข้อมูลปัจจุบัน</h2>
                <div class="space-y-2">
                    <div v-if="currentData.promptPayNumber" class="flex items-center gap-2">
                        <span class="text-xs text-gray-400">เบอร์:</span>
                        <span class="text-sm font-medium text-gray-900">{{ currentData.promptPayNumber }}</span>
                    </div>
                    <div v-if="currentData.promptPayQrUrl">
                        <p class="text-xs text-gray-400 mb-2">QR Code ปัจจุบัน:</p>
                        <img :src="currentData.promptPayQrUrl" alt="QR พร้อมเพย์" class="w-48 h-48 object-contain border rounded-lg" />
                    </div>
                </div>
            </div>

            <!-- Form -->
            <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
                <h2 class="text-sm font-semibold text-gray-700 mb-4">อัปเดตข้อมูลพร้อมเพย์</h2>

                <div class="space-y-4">
                    <!-- Phone Number -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">เบอร์พร้อมเพย์</label>
                        <input v-model="form.promptPayNumber" type="tel" placeholder="0812345678"
                            class="w-full border border-gray-300 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" />
                    </div>

                    <!-- QR Upload -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">อัปโหลดรูป QR Code</label>
                        <div @click="$refs.qrInput.click()"
                            class="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center cursor-pointer hover:border-blue-400 transition">
                            <img v-if="qrPreview" :src="qrPreview" alt="QR Preview"
                                class="w-40 h-40 mx-auto object-contain mb-2" />
                            <div v-else>
                                <svg class="w-10 h-10 mx-auto text-gray-300 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                </svg>
                                <p class="text-sm text-gray-500">คลิกเพื่อเลือกรูป QR Code</p>
                            </div>
                        </div>
                        <input ref="qrInput" type="file" accept="image/*" class="hidden" @change="handleQrSelect" />
                    </div>

                    <!-- Save -->
                    <button @click="handleSave" :disabled="saving || (!form.promptPayNumber && !form.qrFile)"
                        class="w-full bg-blue-600 text-white py-2.5 rounded-lg font-medium text-sm hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition">
                        <span v-if="saving">กำลังบันทึก...</span>
                        <span v-else>บันทึก</span>
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
definePageMeta({ middleware: 'auth' })

const config = useRuntimeConfig()
const { toast } = useToast()

const currentData = ref({ promptPayNumber: null, promptPayQrUrl: null })
const form = ref({ promptPayNumber: '', qrFile: null })
const qrPreview = ref(null)
const saving = ref(false)

// Fetch current user data
onMounted(async () => {
    try {
        const token = useCookie('token').value
        const res = await $fetch('/users/me', {
            baseURL: config.public.apiBase,
            headers: token ? { Authorization: `Bearer ${token}` } : {},
        })
        if (res.data) {
            currentData.value.promptPayNumber = res.data.promptPayNumber
            currentData.value.promptPayQrUrl = res.data.promptPayQrUrl
            if (res.data.promptPayNumber) form.value.promptPayNumber = res.data.promptPayNumber
        }
    } catch (e) { /* ignore */ }
})

function handleQrSelect(event) {
    const file = event.target.files[0]
    if (!file) return
    form.value.qrFile = file
    const reader = new FileReader()
    reader.onload = (e) => { qrPreview.value = e.target.result }
    reader.readAsDataURL(file)
}

async function handleSave() {
    saving.value = true
    try {
        const token = useCookie('token').value
        const formData = new FormData()
        if (form.value.promptPayNumber) formData.append('promptPayNumber', form.value.promptPayNumber)
        if (form.value.qrFile) formData.append('promptPayQrImage', form.value.qrFile)

        const res = await $fetch('/users/me/promptpay', {
            baseURL: config.public.apiBase,
            method: 'PUT',
            body: formData,
            headers: token ? { Authorization: `Bearer ${token}` } : {},
        })

        if (res.data) {
            currentData.value.promptPayNumber = res.data.promptPayNumber
            currentData.value.promptPayQrUrl = res.data.promptPayQrUrl
        }
        toast.success('สำเร็จ', 'บันทึกข้อมูลพร้อมเพย์แล้ว')
    } catch (err) {
        toast.error('ผิดพลาด', err?.data?.message || 'ไม่สามารถบันทึกได้')
    } finally {
        saving.value = false
    }
}
</script>

<style scoped>
.font-kanit { font-family: 'Kanit', sans-serif; }
</style>
