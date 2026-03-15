<template>
    <div class="min-h-screen bg-gray-100 font-kanit">
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

            <!-- Receipt -->
            <div v-else-if="receipt">
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

                <!-- Receipt Document -->
                <div id="receipt-content" class="bg-white border border-gray-300 shadow-sm">
                    <!-- Header -->
                    <div class="px-8 pt-8 pb-4 border-b-2 border-gray-800">
                        <div class="flex items-start justify-between">
                            <div>
                                <h2 class="text-xl font-bold text-gray-900">PaiNamNae</h2>
                                <p class="text-xs text-gray-500">ระบบร่วมเดินทาง</p>
                            </div>
                            <div class="text-right">
                                <h1 class="text-2xl font-bold text-gray-900">ใบเสร็จรับเงิน</h1>
                                <p class="text-sm text-gray-500">Receipt</p>
                            </div>
                        </div>
                    </div>

                    <!-- Receipt Number & Date -->
                    <div class="px-8 py-4 grid grid-cols-2 gap-4 text-sm border-b border-gray-200">
                        <div>
                            <span class="text-gray-500">เลขที่ (No.)</span>
                            <p class="font-mono font-bold text-gray-900 mt-0.5">{{ receipt.receiptNumber }}</p>
                        </div>
                        <div class="text-right">
                            <span class="text-gray-500">วันที่ (Date)</span>
                            <p class="text-gray-900 font-medium mt-0.5">{{ formatDate(receipt.confirmedAt) }}</p>
                        </div>
                    </div>

                    <!-- Parties -->
                    <div class="px-8 py-4 border-b border-gray-200">
                        <table class="w-full text-sm">
                            <tbody>
                                <tr>
                                    <td class="py-1.5 text-gray-500 w-40">ผู้รับเงิน (คนขับ)</td>
                                    <td class="py-1.5 text-gray-900 font-medium">{{ driverName }}</td>
                                </tr>
                                <tr>
                                    <td class="py-1.5 text-gray-500">ผู้จ่ายเงิน (ผู้โดยสาร)</td>
                                    <td class="py-1.5 text-gray-900 font-medium">{{ passengerName }}</td>
                                </tr>
                                <tr v-if="vehiclePlate">
                                    <td class="py-1.5 text-gray-500">ทะเบียนรถยนต์</td>
                                    <td class="py-1.5 text-gray-900 font-medium">{{ vehiclePlate }}</td>
                                </tr>
                                <tr v-if="vehicleDesc">
                                    <td class="py-1.5 text-gray-500">รถยนต์</td>
                                    <td class="py-1.5 text-gray-900">{{ vehicleDesc }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Details Table -->
                    <div class="px-8 py-4 border-b border-gray-200">
                        <table class="w-full text-sm border border-gray-300">
                            <thead>
                                <tr class="bg-gray-50">
                                    <th class="text-left py-2 px-3 border-b border-gray-300 font-semibold text-gray-700">รายการ</th>
                                    <th class="text-center py-2 px-3 border-b border-gray-300 font-semibold text-gray-700 w-20">จำนวน</th>
                                    <th class="text-right py-2 px-3 border-b border-gray-300 font-semibold text-gray-700 w-24">หน่วยละ</th>
                                    <th class="text-right py-2 px-3 border-b border-gray-300 font-semibold text-gray-700 w-28">จำนวนเงิน</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td class="py-3 px-3 border-b border-gray-200 text-gray-900">
                                        ค่าร่วมเดินทาง
                                        <p class="text-xs text-gray-500 mt-0.5">{{ routeDisplay }}</p>
                                    </td>
                                    <td class="text-center py-3 px-3 border-b border-gray-200 text-gray-700">{{ receipt.booking?.numberOfSeats }}</td>
                                    <td class="text-right py-3 px-3 border-b border-gray-200 text-gray-700">{{ formatNumber(receipt.booking?.route?.pricePerSeat) }}</td>
                                    <td class="text-right py-3 px-3 border-b border-gray-200 font-semibold text-gray-900">{{ formatNumber(receipt.amount) }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Total -->
                    <div class="px-8 py-5 border-b border-gray-200">
                        <div class="flex justify-between items-center">
                            <span class="text-lg font-bold text-gray-900">ยอดรวมทั้งสิ้น</span>
                            <span class="text-2xl font-bold text-gray-900">{{ formatNumber(receipt.amount) }} บาท</span>
                        </div>
                        <p class="text-xs text-gray-400 text-right mt-1">* ไม่รวม VAT (บุคคลธรรมดา)</p>
                    </div>

                    <!-- Payment Info -->
                    <div class="px-8 py-4 border-b border-gray-200">
                        <table class="w-full text-sm">
                            <tbody>
                                <tr>
                                    <td class="py-1.5 text-gray-500 w-40">วิธีชำระเงิน</td>
                                    <td class="py-1.5 text-gray-900">{{ receipt.method === 'CASH' ? 'เงินสด' : 'โอนเงิน' }}</td>
                                </tr>
                                <tr>
                                    <td class="py-1.5 text-gray-500">สถานะ</td>
                                    <td class="py-1.5 text-green-700 font-medium">ชำระแล้ว</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Footer -->
                    <div class="px-8 py-5 text-center">
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

const vehiclePlate = computed(() => receipt.value?.booking?.route?.vehicle?.licensePlate || '')

const vehicleDesc = computed(() => {
    const v = receipt.value?.booking?.route?.vehicle
    if (!v) return ''
    return [v.brand, v.model, v.color].filter(Boolean).join(' ')
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

function formatNumber(num) {
    return Number(num || 0).toLocaleString('th-TH', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

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

    @page {
        size: A4;
        margin: 15mm;
    }

    #receipt-content {
        border: none !important;
        box-shadow: none !important;
    }
}
</style>
