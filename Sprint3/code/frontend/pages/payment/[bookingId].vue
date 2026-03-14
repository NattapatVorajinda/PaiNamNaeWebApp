<template>
    <div class="min-h-screen bg-gray-50 font-kanit">
        <div class="max-w-lg mx-auto px-4 py-8">
            <!-- Loading -->
            <div v-if="loading" class="flex justify-center py-20">
                <div class="animate-spin w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full"></div>
            </div>

            <!-- Error -->
            <div v-else-if="error" class="text-center py-20">
                <p class="text-red-500 mb-4">{{ error }}</p>
                <NuxtLink to="/myTrip" class="text-blue-600 hover:underline text-sm">กลับไปหน้ารายการเดินทาง</NuxtLink>
            </div>

            <!-- Payment Page -->
            <div v-else-if="payment">
                <!-- Header -->
                <div class="mb-6">
                    <NuxtLink to="/myTrip" class="text-sm text-blue-600 hover:underline flex items-center gap-1 mb-2">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                        </svg>
                        กลับไปหน้าเดินทาง
                    </NuxtLink>
                    <h1 class="text-2xl font-bold text-gray-900">ชำระเงิน</h1>
                </div>

                <!-- Trip Summary -->
                <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100 mb-4">
                    <h2 class="text-sm font-semibold text-gray-700 mb-3">รายละเอียดการเดินทาง</h2>
                    <div class="space-y-2 text-sm">
                        <div class="flex justify-between">
                            <span class="text-gray-500">เส้นทาง</span>
                            <span class="text-gray-900 font-medium text-right max-w-[60%] truncate">
                                {{ routeDisplay }}
                            </span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-gray-500">คนขับ</span>
                            <span class="text-gray-900">{{ driverName }}</span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-gray-500">จำนวนที่นั่ง</span>
                            <span class="text-gray-900">{{ payment.booking?.numberOfSeats }} ที่นั่ง</span>
                        </div>
                        <div class="flex justify-between items-center pt-2 border-t border-gray-100">
                            <span class="text-gray-700 font-semibold">ยอดรวม</span>
                            <span class="text-xl font-bold text-blue-600">฿{{ payment.amount?.toLocaleString() }}</span>
                        </div>
                    </div>
                </div>

                <!-- Status Badge -->
                <div v-if="payment.status !== 'PENDING'" class="mb-4">
                    <div v-if="payment.status === 'PAID'" class="bg-yellow-50 border border-yellow-200 rounded-xl p-4 text-center">
                        <p class="text-yellow-700 font-medium">⏳ รอคนขับยืนยันรับเงิน</p>
                    </div>
                    <div v-else-if="payment.status === 'CONFIRMED'" class="bg-green-50 border border-green-200 rounded-xl p-4 text-center">
                        <p class="text-green-700 font-medium">✅ ชำระเงินเรียบร้อยแล้ว</p>
                        <NuxtLink :to="`/receipt/${route.params.bookingId}`"
                            class="inline-block mt-2 text-sm text-green-600 hover:underline">ดูใบเสร็จ →</NuxtLink>
                    </div>
                </div>

                <!-- Payment Methods (only if PENDING) -->
                <div v-if="payment.status === 'PENDING'" class="space-y-4">
                    <!-- Method Selection -->
                    <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
                        <h2 class="text-sm font-semibold text-gray-700 mb-3">เลือกวิธีชำระเงิน</h2>
                        <div class="grid grid-cols-2 gap-3">
                            <button @click="selectedMethod = 'CASH'"
                                :class="['method-btn', selectedMethod === 'CASH' ? 'method-btn-active' : '']">
                                <span class="text-2xl">💵</span>
                                <span class="text-sm font-medium">เงินสด</span>
                            </button>
                            <button @click="selectedMethod = 'TRANSFER'"
                                :class="['method-btn', selectedMethod === 'TRANSFER' ? 'method-btn-active' : '']">
                                <span class="text-2xl">📱</span>
                                <span class="text-sm font-medium">โอนเงิน</span>
                            </button>
                        </div>
                    </div>

                    <!-- Transfer: Show QR -->
                    <div v-if="selectedMethod === 'TRANSFER'" class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
                        <h2 class="text-sm font-semibold text-gray-700 mb-3">QR พร้อมเพย์คนขับ</h2>
                        <div v-if="driverPromptPay.qrUrl || driverPromptPay.number" class="text-center">
                            <img v-if="driverPromptPay.qrUrl" :src="driverPromptPay.qrUrl"
                                alt="QR พร้อมเพย์" class="w-56 h-56 mx-auto object-contain border rounded-lg mb-3" />
                            <p v-if="driverPromptPay.number" class="text-sm text-gray-600">
                                เบอร์พร้อมเพย์: <strong>{{ driverPromptPay.number }}</strong>
                            </p>

                            <!-- Slip Upload -->
                            <div class="mt-4 text-left">
                                <label class="block text-sm font-medium text-gray-700 mb-1">แนบสลิปโอนเงิน</label>
                                <div @click="$refs.slipInput.click()"
                                    class="border-2 border-dashed border-gray-300 rounded-lg p-4 text-center cursor-pointer hover:border-blue-400 transition">
                                    <img v-if="slipPreview" :src="slipPreview" class="w-32 mx-auto object-contain mb-2" />
                                    <p v-else class="text-sm text-gray-500">คลิกเพื่อแนบสลิป</p>
                                </div>
                                <input ref="slipInput" type="file" accept="image/*" class="hidden" @change="handleSlipSelect" />
                            </div>
                        </div>
                        <div v-else class="text-center text-gray-400 py-4">
                            <p class="text-sm">คนขับยังไม่ได้ตั้งค่าพร้อมเพย์</p>
                            <p class="text-xs mt-1">กรุณาเลือกจ่ายเงินสดแทน</p>
                        </div>
                    </div>

                    <!-- Submit -->
                    <button v-if="selectedMethod" @click="handlePay" :disabled="submitting || (selectedMethod === 'TRANSFER' && !slipFile)"
                        class="w-full bg-blue-600 text-white py-3 rounded-xl font-semibold text-sm hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition shadow-sm">
                        <span v-if="submitting">กำลังดำเนินการ...</span>
                        <span v-else-if="selectedMethod === 'CASH'">ยืนยันจ่ายเงินสด</span>
                        <span v-else>ยืนยันโอนเงินแล้ว</span>
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
definePageMeta({ middleware: 'auth' })

const route = useRoute()
const config = useRuntimeConfig()
const { toast } = useToast()

const loading = ref(true)
const error = ref(null)
const payment = ref(null)
const selectedMethod = ref(null)
const slipFile = ref(null)
const slipPreview = ref(null)
const submitting = ref(false)

const driverName = computed(() => {
    const d = payment.value?.booking?.route?.driver
    return d ? `${d.firstName} ${d.lastName}` : '-'
})

const routeDisplay = computed(() => {
    const r = payment.value?.booking?.route
    if (!r) return '-'
    const start = r.startLocation
    const end = r.endLocation
    const startName = typeof start === 'object' ? (start.name || `${Number(start.lat).toFixed(2)},${Number(start.lng).toFixed(2)}`) : start
    const endName = typeof end === 'object' ? (end.name || `${Number(end.lat).toFixed(2)},${Number(end.lng).toFixed(2)}`) : end
    return `${startName} → ${endName}`
})

const driverPromptPay = computed(() => ({
    number: payment.value?.booking?.route?.driver?.promptPayNumber,
    qrUrl: payment.value?.booking?.route?.driver?.promptPayQrUrl,
}))

onMounted(async () => {
    try {
        const token = useCookie('token').value
        const res = await $fetch(`/payments/booking/${route.params.bookingId}`, {
            baseURL: config.public.apiBase,
            headers: token ? { Authorization: `Bearer ${token}` } : {},
        })
        payment.value = res.data
    } catch (err) {
        error.value = err?.data?.message || 'ไม่พบข้อมูลการชำระเงิน'
    } finally {
        loading.value = false
    }
})

function handleSlipSelect(event) {
    const file = event.target.files[0]
    if (!file) return
    slipFile.value = file
    const reader = new FileReader()
    reader.onload = (e) => { slipPreview.value = e.target.result }
    reader.readAsDataURL(file)
}

async function handlePay() {
    submitting.value = true
    try {
        const token = useCookie('token').value
        const formData = new FormData()
        formData.append('method', selectedMethod.value)
        if (slipFile.value) formData.append('slip', slipFile.value)

        const res = await $fetch(`/payments/booking/${route.params.bookingId}/pay`, {
            baseURL: config.public.apiBase,
            method: 'POST',
            body: formData,
            headers: token ? { Authorization: `Bearer ${token}` } : {},
        })

        payment.value = { ...payment.value, ...res.data }
        toast.success('สำเร็จ', selectedMethod.value === 'CASH' ? 'แจ้งจ่ายเงินสดแล้ว รอคนขับยืนยัน' : 'แจ้งโอนเงินแล้ว รอคนขับยืนยัน')
    } catch (err) {
        toast.error('ผิดพลาด', err?.data?.message || 'ไม่สามารถดำเนินการได้')
    } finally {
        submitting.value = false
    }
}
</script>

<style scoped>
.font-kanit { font-family: 'Kanit', sans-serif; }

.method-btn {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.5rem;
    padding: 1rem;
    border-radius: 0.75rem;
    border: 2px solid #e5e7eb;
    background: white;
    cursor: pointer;
    transition: all 0.2s;
}
.method-btn:hover { border-color: #93c5fd; }
.method-btn-active {
    border-color: #2563eb;
    background-color: #eff6ff;
}
</style>
