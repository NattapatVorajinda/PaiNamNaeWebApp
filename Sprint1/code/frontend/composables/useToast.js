import { ref } from 'vue'

const toasts = ref([])

export function useToast() {
    const addToast = (toast) => {
        const id = Date.now() + Math.random()
        toasts.value.push({ ...toast, id })
        // Auto-dismiss after duration (default 4s)
        setTimeout(() => {
            toasts.value = toasts.value.filter(t => t.id !== id)
        }, toast.duration || 4000)
    }

    const removeToast = (id) => {
        toasts.value = toasts.value.filter(toast => toast.id !== id)
    }

    const toast = {
        success: (title, message, duration) => {
            addToast({ type: 'success', title, message, duration })
        },
        error: (title, message, duration) => {
            addToast({ type: 'error', title, message, duration })
        },
        warning: (title, message, duration) => {
            addToast({ type: 'warning', title, message, duration })
        },
        info: (title, message, duration) => {
            addToast({ type: 'info', title, message, duration })
        },
    }

    return { toasts, addToast, removeToast, toast }
}