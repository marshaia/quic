
export const SessionStore = {
  mounted() {
    this.handleEvent("store", (obj) => {
      sessionStorage.setItem(obj.key, obj.data)
    })
    this.handleEvent("clear", (obj) => {
      sessionStorage.removeItem(obj.key)
    })
  }
};
