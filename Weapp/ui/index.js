const set = (obj, path, value) => {
  // Regex explained: https://regexr.com/58j0k
  const pathArray = Array.isArray(path) ? path : path.match(/([^[.\]])+/g)

  pathArray.reduce((acc, key, i) => {
    if (acc[key] === undefined) acc[key] = {}
    if (i === pathArray.length - 1) acc[key] = value
    return acc[key]
  }, obj)
}

class RuntimeManager {
    constructor() {
        this.page = null
        this.pageId = ''
        this.uiInstance = {}
    }

    firstRender(pagePath, bridgeId) {
        this.pageId = bridgeId
        const options = this.makeVueOptions(pagePath, bridgeId)
        this.page = new Vue(options)
        this.page.$mount('#app')
    }

    updateModule(bridgeId, data) {
        const instance = this.uiInstance[bridgeId]

        for (let key in data) {
            set(instance, key, data[key])
        }
        console.log(instance)
        instance.$forceUpdate()
    }

    makeVueOptions(path, bridgeId) {
        const staticModule = loader.staticModules.get(path)
        const pageId = this.pageId
        const uiInstance = this.uiInstance
        return {
            _scopeId: staticModule.scopeId,
            data() {
                return {
                    ...staticModule.data
                }
            },
            render: staticModule.render,
            beforeCreate() {
                this._bridgeInfo = {
                    id: bridgeId,
                }
            },
            created() {
                uiInstance[bridgeId] = this
                sentMessageToNative('moduleCreated', {
                    id: pageId,
                    path,
                })
            },
        }
    }
}

const runtimeManager = new RuntimeManager()

class Loader {
    constructor() {
        this.staticModules = new Map()
    }

    loadResources({ appId, pagePath }) {
        Promise.all([this.loadStyle(appId), this.loadScript(appId)])
            .then(() => {
                modRequire(pagePath)
                sentMessageToNative('uiResourceLoaded', {})
            })
    }

    loadStyle(appId) {
        return new Promise((resolve) => {
            const link = document.createElement('link')
            link.setAttribute('rel', 'stylesheet')
            link.href = `http://192.168.31.134:3000/apps/${appId}/style.css`
            link.onload = () => {
                resolve()
            }
            document.body.appendChild(link)
        })
    }

    loadScript(appId) {
        return new Promise((resolve) => {
            const script = document.createElement('script')
            script.src = `http://192.168.31.134:3000/apps/${appId}/view.js`
            script.onload = () => {
                resolve()
            }
            document.body.appendChild(script)
        })
    }

    createPageInfo(pageInfo) {
        this.staticModules.set(pageInfo.path, pageInfo)
    }

    setInitialData(initialData, pagePath) {
        const staticModule = this.staticModules.get(pagePath)
        staticModule.data = initialData
    }
}

let loader = new Loader()

function onMessage(payload) {
    const {
        type,
        body,
    } = payload

    if (type === "loadResource") {
        loader.loadResources(body)
    } else if (type === 'setInitialData') {
        const {
            initialData,
            pagePath,
            bridgeId,
        } = body
        loader.setInitialData(initialData, pagePath)
        runtimeManager.firstRender(pagePath, bridgeId)
    } else if (type === 'updateModule') {
        const {
            bridgeId,
            data,
        } = body
        runtimeManager.updateModule(bridgeId, data)
    }
}

function Page(pageInfo) {
    loader.createPageInfo(pageInfo)
}

function abc() {
//    console.log(1)
//    webkit.messageHandlers.ui.postMessage({
//        type: "来自ui线程的消息"
//    })
    runtimeManager.firstRender('pages/home/index', '342DC465-57AE-4D07-9951-6922EA019170')
}

function sentMessageToNative(type, body) {
    webkit.messageHandlers.ui.postMessage({
        type,
        body,
    })
}
