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
                <NuxtLink to="/myTrip" class="text-blue-600 hover:underline text-sm">กลับ</NuxtLink>
            </div>

            <!-- Receipt -->
            <div v-else-if="receipt" id="receipt-content">
                <!-- Actions (hide on print) -->
                <div class="print:hidden mb-6 flex items-center justify-between">
                    <NuxtLink to="/myTrip" class="text-sm text-blue-600 hover:underline flex items-center gap-1">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                        </svg>
                        กลับ
                    </NuxtLink>
                    <button @click="printReceipt"
                        class="flex items-center gap-1.5 bg-blue-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                        </svg>
                        พิมพ์ / บันทึก PDF
                    </button>
                </div>

                <!-- Receipt Card -->
                <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                    <!-- Header -->
                    <div class="bg-gradient-to-r from-blue-600 to-blue-700 text-white p-6 text-center">
                        <h1 class="text-xl font-bold">ใบเสร็จรับเงิน</h1>
                        <p class="text-blue-100 text-xs mt-1">Receipt</p>
                    </div>

                    <!-- Receipt Number & Date -->
                    <div class="px-6 pt-5 pb-3 flex justify-between text-sm border-b border-gray-100">
                        <div>
                            <span class="text-gray-400 text-xs">เลขที่</span>
                            <p class="font-mono font-bold text-gray-900">{{ receipt.receiptNumber }}</p>
                        </div>
                        <div class="text-right">
                            <span class="text-gray-400 text-xs">วันที่</span>
                            <p class="text-gray-900">{{ formatDate(receipt.confirmedAt) }}</p>
                        </div>
                    </div>

                    <!-- Parties -->
                    <div class="px-6 py-4 border-b border-gray-100 space-y-3">
                        <div class="flex justify-between text-sm">
                            <span class="text-gray-500">ผู้รับเงิน (คนขับ)</span>
                            <span class="text-gray-900 font-medium">{{ driverName }}</span>
                        </div>
                        <div class="flex justify-between text-sm">
                            <span class="text-gray-500">ผู้จ่ายเงิน (ผู้โดยสาร)</span>
                            <span class="text-gray-900 font-medium">{{ passengerName }}</span>
                        </div>
                    </div>

                    <!-- Details Table -->
                    <div class="px-6 py-4 border-b border-gray-100">
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="text-gray-400 text-xs uppercase">
                                    <th class="text-left pb-2">รายการ</th>
                                    <th class="text-center pb-2">จำนวน</th>
                                    <th class="text-right pb-2">หน่วยละ</th>
                                    <th class="text-right pb-2">จำนวนเงิน</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td class="py-2 text-gray-900">
                                        ค่าร่วมเดินทาง
                                        <p class="text-xs text-gray-400">{{ routeDisplay }}</p>
                                    </td>
                                    <td class="text-center text-gray-700">{{ receipt.booking?.numberOfSeats }}</td>
                                    <td class="text-right text-gray-700">฿{{ receipt.booking?.route?.pricePerSeat?.toLocaleString() }}</td>
                                    <td class="text-right font-semibold text-gray-900">฿{{ receipt.amount?.toLocaleString() }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Total -->
                    <div class="px-6 py-4 border-b border-gray-100">
                        <div class="flex justify-between items-center">
                            <span class="text-gray-700 font-semibold">ยอดรวมทั้งสิ้น</span>
                            <span class="text-2xl font-bold text-blue-600">฿{{ receipt.amount?.toLocaleString() }}</span>
                        </div>
                        <p class="text-xs text-gray-400 text-right mt-1">* ไม่รวม VAT (บุคคลธรรมดา)</p>
                    </div>

                    <!-- Payment Method -->
                    <div class="px-6 py-4 space-y-2 text-sm">
                        <div class="flex justify-between">
                            <span class="text-gray-500">วิธีชำระเงิน</span>
                            <span class="text-gray-900">{{ receipt.method === 'CASH' ? 'เงินสด' : 'โอนเงิน' }}</span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-gray-500">สถานะ</span>
                            <span class="text-green-600 font-medium">✅ ชำระแล้ว</span>
                        </div>
                    </div>

                    <!-- Footer -->
                    <div class="bg-gray-50 px-6 py-4 text-center">
                        <p class="text-xs text-gray-400">เอกสารนี้ออกโดยระบบอัตโนมัติ — PaiNamNae Carpool</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
definePageMeta({ middleware: 'auth' })

const route = useRoute()
const config = useRuntimeConfig()

const loading = ref(true)
const error = ref(null)
const receipt = ref(null)

const driverName = computed(() => {
    const d = receipt.value?.booking?.route?.driver
    return d ? `${d.firstName} ${d.lastName}` : '-'
})

const passengerName = computed(() => {
    const p = receipt.value?.booking?.passenger
    return p ? `${p.firstName} ${p.lastName}` : '-'
})

const routeDisplay = computed(() => {
    const r = receipt.value?.booking?.route
    if (!r) return ''
    const start = r.startLocation
    const end = r.endLocation
    const startName = typeof start === 'object' ? (start.name || '') : start
    const endName = typeof end === 'object' ? (end.name || '') : end
    return startName && endName ? `${startName} → ${endName}` : ''
})

function formatDate(dateStr) {
    if (!dateStr) return '-'
    const d = new Date(dateStr)
    return d.toLocaleDateString('th-TH', { year: 'numeric', month: 'long', day: 'numeric' })
}

function printReceipt() {
    window.print()
}

onMounted(async () => {
    try {
        const token = useCookie('token').value
        const res = await $fetch(`/payments/booking/${route.params.bookingId}/receipt`, {
            baseURL: config.public.apiBase,
            headers: token ? { Authorization: `Bearer ${token}` } : {},
        })
        receipt.value = res.data
    } catch (err) {
        error.value = err?.data?.message || 'ไม่พบใบเสร็จ'
    } finally {
        loading.value = false
    }
})
</script>

<style scoped>
.font-kanit { font-family: 'Kanit', sans-serif; }

@media print {
    body { background: white !important; }
    .print\:hidden { display: none !important; }
}
</style>
