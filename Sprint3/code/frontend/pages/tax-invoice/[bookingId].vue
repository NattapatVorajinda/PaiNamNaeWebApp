<template>
    <div class="min-h-screen bg-gray-50 font-kanit">
        <div class="max-w-2xl mx-auto px-4 py-8">
            <!-- Loading -->
            <div v-if="loading" class="flex justify-center py-20">
                <div class="animate-spin w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full"></div>
            </div>

            <!-- Error -->
            <div v-else-if="error" class="text-center py-20">
                <p class="text-red-500 mb-4">{{ error }}</p>
                <NuxtLink to="/myTrip" class="text-blue-600 hover:underline text-sm">กลับ</NuxtLink>
            </div>

            <!-- Tax Invoice -->
            <div v-else-if="receipt">
                <!-- Actions (hide on print) -->
                <div class="print:hidden mb-6 flex items-center justify-between">
                    <NuxtLink :to="`/payment/${route.params.bookingId}`" class="text-sm text-blue-600 hover:underline flex items-center gap-1">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                        </svg>
                        กลับ
                    </NuxtLink>
                    <button @click="printInvoice"
                        class="flex items-center gap-1.5 bg-blue-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                        </svg>
                        พิมพ์ / บันทึก PDF
                    </button>
                </div>

                <!-- Invoice Card -->
                <div id="invoice-content" class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                    <!-- Header -->
                    <div class="px-8 pt-8 pb-4">
                        <div class="flex items-start justify-between">
                            <div>
                                <span class="text-lg font-bold text-gray-800">PaiNamNae</span>
                                <p class="text-xs text-gray-400">ระบบร่วมเดินทาง</p>
                            </div>
                            <div class="text-right">
                                <h1 class="text-xl font-bold text-gray-900">ใบเสร็จรับเงิน / ใบกำกับภาษี</h1>
                                <p class="text-xs text-gray-400 mt-0.5">Receipt / Tax Invoice</p>
                            </div>
                        </div>
                    </div>

                    <!-- Invoice Number & Date -->
                    <div class="px-8 py-3 flex justify-between text-sm border-b border-gray-200">
                        <div class="flex gap-6">
                            <div>
                                <span class="text-gray-400 text-xs">วันที่</span>
                                <p class="text-gray-900 font-medium">{{ formatDate(receipt.confirmedAt) }}</p>
                            </div>
                        </div>
                        <div class="flex gap-6 text-right">
                            <div>
                                <span class="text-gray-400 text-xs">เลขที่</span>
                                <p class="font-mono font-bold text-gray-900">{{ receipt.receiptNumber }}</p>
                            </div>
                        </div>
                    </div>

                    <!-- Seller Info -->
                    <div class="px-8 py-4 border-b border-gray-200">
                        <p class="text-sm text-gray-900">
                            <span class="text-gray-500">ชื่อผู้ขาย</span>
                            <span class="ml-4 font-medium">{{ driverName }}</span>
                        </p>
                        <p v-if="driverEmail" class="text-sm mt-1">
                            <span class="text-gray-500">อีเมล</span>
                            <span class="ml-4 text-gray-900">{{ driverEmail }}</span>
                        </p>
                        <p v-if="driverPhone" class="text-sm mt-1">
                            <span class="text-gray-500">โทรศัพท์</span>
                            <span class="ml-4 text-gray-900">{{ driverPhone }}</span>
                        </p>
                    </div>

                    <!-- Buyer Info -->
                    <div class="px-8 py-4 border-b border-gray-200">
                        <p class="text-sm text-gray-900">
                            <span class="text-gray-500">ชื่อผู้ซื้อ</span>
                            <span class="ml-4 font-medium">{{ passengerName }}</span>
                        </p>
                        <p v-if="passengerEmail" class="text-sm mt-1">
                            <span class="text-gray-500">อีเมล</span>
                            <span class="ml-4 text-gray-900">{{ passengerEmail }}</span>
                        </p>
                    </div>

                    <!-- Details Table -->
                    <div class="px-8 py-4 border-b border-gray-200">
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="text-gray-400 text-xs uppercase border-b border-gray-200">
                                    <th class="text-left pb-2 w-10">ลำดับ</th>
                                    <th class="text-left pb-2">รายการ</th>
                                    <th class="text-center pb-2 w-16">จำนวน</th>
                                    <th class="text-right pb-2 w-24">หน่วยละ</th>
                                    <th class="text-right pb-2 w-28">จำนวนเงิน</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td class="py-3 text-gray-700 text-center">1</td>
                                    <td class="py-3 text-gray-900">
                                        ค่าร่วมเดินทาง
                                        <p class="text-xs text-gray-400">{{ routeDisplay }}</p>
                                    </td>
                                    <td class="text-center text-gray-700">{{ receipt.booking?.numberOfSeats }}</td>
                                    <td class="text-right text-gray-700">{{ formatNumber(pricePerSeat) }}</td>
                                    <td class="text-right font-semibold text-gray-900">{{ formatNumber(amountBeforeVat) }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Totals -->
                    <div class="px-8 py-4 border-b border-gray-200">
                        <div class="space-y-2 max-w-xs ml-auto text-sm">
                            <div class="flex justify-between">
                                <span class="text-gray-500">มูลค่ารวมก่อนเสียภาษี</span>
                                <span class="text-gray-900">{{ formatNumber(amountBeforeVat) }}</span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-500">ภาษีมูลค่าเพิ่ม (VAT) 7%</span>
                                <span class="text-gray-900">{{ formatNumber(vatAmount) }}</span>
                            </div>
                            <div class="flex justify-between items-center pt-2 border-t border-gray-200">
                                <span class="text-gray-900 font-bold">ยอดรวม</span>
                                <span class="text-xl font-bold text-gray-900">{{ formatNumber(totalWithVat) }}</span>
                            </div>
                        </div>
                    </div>

                    <!-- Payment Method -->
                    <div class="px-8 py-4 space-y-2 text-sm border-b border-gray-200">
                        <div class="flex justify-between">
                            <span class="text-gray-500">วิธีชำระเงิน</span>
                            <span class="text-gray-900">{{ receipt.method === 'CASH' ? 'เงินสด' : 'โอนเงิน' }}</span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-gray-500">สถานะ</span>
                            <span class="text-gray-900 font-medium">ชำระแล้ว</span>
                        </div>
                    </div>

                    <!-- Footer -->
                    <div class="bg-gray-50 px-8 py-4 text-center">
                        <p class="text-xs text-gray-400">เอกสารนี้ออกโดยระบบอัตโนมัติ — PaiNamNae Carpool</p>
                        <p class="text-xs text-gray-400 mt-0.5">ใบเสร็จรับเงิน / ใบกำกับภาษี</p>
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

const driverEmail = computed(() => receipt.value?.booking?.route?.driver?.email || '')
const driverPhone = computed(() => receipt.value?.booking?.route?.driver?.phoneNumber || '')

const passengerName = computed(() => {
    const p = receipt.value?.booking?.passenger
    return p ? `${p.firstName} ${p.lastName}` : '-'
})

const passengerEmail = computed(() => receipt.value?.booking?.passenger?.email || '')

const routeDisplay = computed(() => {
    const r = receipt.value?.booking?.route
    if (!r) return ''
    const start = r.startLocation
    const end = r.endLocation
    const startName = typeof start === 'object' ? (start.name || '') : start
    const endName = typeof end === 'object' ? (end.name || '') : end
    return startName && endName ? `${startName} → ${endName}` : ''
})

const pricePerSeat = computed(() => receipt.value?.booking?.route?.pricePerSeat || 0)

// VAT calculation: amount is the total paid, we back-calculate the pre-VAT amount
const totalWithVat = computed(() => receipt.value?.amount || 0)
const amountBeforeVat = computed(() => {
    const total = totalWithVat.value
    return Math.round((total / 1.07) * 100) / 100
})
const vatAmount = computed(() => {
    return Math.round((totalWithVat.value - amountBeforeVat.value) * 100) / 100
})

function formatNumber(num) {
    return Number(num).toLocaleString('th-TH', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

function formatDate(dateStr) {
    if (!dateStr) return '-'
    const d = new Date(dateStr)
    return d.toLocaleDateString('th-TH', { year: 'numeric', month: 'long', day: 'numeric' })
}

function printInvoice() {
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
        error.value = err?.data?.message || 'ไม่พบข้อมูลใบเสร็จ'
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
