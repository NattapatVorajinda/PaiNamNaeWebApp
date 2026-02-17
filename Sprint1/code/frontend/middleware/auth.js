export default defineNuxtRouteMiddleware(async (to) => {
  if (process.server) return

  // รอให้ client hydrate เสร็จก่อนอ่าน cookie
  await nextTick()

  const token = useCookie('token').value
  if (!token && to.path !== '/login') {
    return navigateTo('/login')
  }
})