let modDefine
let modRequire

(function() {
  var defineCache = {};
  var requireCache = {};
  var loadingModules = {};

  // 模块定义函数
  function define(id, factory) {
    if (!defineCache[id]) {
      var module = {
        id: id,
        dependencies: [],
        factory: factory
      };
      defineCache[id] = module;
    }
  }

  // 模块加载函数
  function require(id) {
    if (loadingModules[id]) {
      return {};
    }

    if (!requireCache[id]) {
      var mod = defineCache[id];
      if (!mod) throw new Error("No module defined with id " + id);

      var module = {
        exports: {}
      };
      loadingModules[id] = true;
      var factoryArgs = [require, module.exports, module];

      mod.factory.apply(null, factoryArgs);
      requireCache[id] = module.exports;
      delete loadingModules[id];
    }
    return requireCache[id];
  }

    modDefine = define;
    modRequire = require;
})();


const wx = {}

wx.navigateTo = function ({ url }) {
    NativeAPI.sendMessage({
        type: 'triggerWXAPI',
        body: {
            apiName: 'navigateTo',
            params: {
                url,
            }
        }
    })
}

wx.navigateBack = function() {
    NativeAPI.sendMessage({
        type: 'triggerWXAPI',
        body: {
            apiName: 'navigateBack',
        }
    })
}

class VideoContext {
    constructor(videoId) {
        this.videoId = videoId
    }

    pause() {
        const currentPageInfo = navigation.getCurrentPageInfo()

        NativeAPI.sendMessage({
            type: 'pauseVideo',
            body: {
                videoId: this.videoId,
                bridgeId: currentPageInfo.bridgeId
            }
        })
    }

    play() {
        const currentPageInfo = navigation.getCurrentPageInfo()

        NativeAPI.sendMessage({
            type: 'playVideo',
            body: {
                videoId: this.videoId,
                bridgeId: currentPageInfo.bridgeId
            }
        })
    }
}

wx.createVideoContext = function(id) {
    return new VideoContext(id)
}

const set = (obj, path, value) => {
  // Regex explained: https://regexr.com/58j0k
  const pathArray = Array.isArray(path) ? path : path.match(/([^[.\]])+/g)

  pathArray.reduce((acc, key, i) => {
    if (acc[key] === undefined) acc[key] = {}
    if (i === pathArray.length - 1) acc[key] = value
    return acc[key]
  }, obj)
}

class AppInstance {
    constructor(moduleInfo, openInfo) {
        this.moduleInfo = moduleInfo
        this.openInfo = openInfo
        this.init()
    }

    init() {
        this.initLifecycle()
        this.callLifecycle()
    }

    initLifecycle() {
        const lifecycles = ['onLaunch', 'onShow', 'onHide']
        lifecycles.forEach(name => {
            if (typeof this.moduleInfo[name] === 'function') {
                this[name] = this.moduleInfo[name].bind(this)
            }
        })
    }

    callLifecycle() {
        // 可以传参数，如场景值等
        this.onLaunch && this.onLaunch()
        this.onShow && this.onShow()
    }
}

class PageInstance {
    constructor(pageModeule, { bridgeId, query }) {
        this.pageModeule = pageModeule
        this.id = bridgeId
        this.data = JSON.parse(JSON.stringify(pageModeule.data))
        this.initLifecycle()
        this.initMethods()
        this.onLoad(query)
        this.onShow()
    }

    initLifecycle() {
        const lifecycles = ['onLoad', 'onShow', 'onHide', 'onReady', 'onUnload', 'onPageScroll']
        lifecycles.forEach(name => {
            this[name] = this.pageModeule[name].bind(this) // TODO: 检查是函数
        })
    }

    initMethods() {
        const pageInfo = this.pageModeule

        for (let attr in pageInfo) {
            if (typeof pageInfo[attr] === 'function' && !this.hasOwnProperty(pageInfo[attr])) {
                this[attr] = pageInfo[attr].bind(this)
            }
        }
    }

    setData(data) {
        const pageInfo = this.pageModeule

        for (let key in data) {
            set(this.data, key, data[key])
        }

        NativeAPI.sendMessage({
            type: 'updateModule',
            body: {
                bridgeId: this.id,
                data,
            }
        })
    }
}

class Navigation {
    constructor() {
        this.stack = []
    }

    pushState(pageInfo) {
        this.stack.push(pageInfo)
    }

    popState() {
        this.stack.pop()
    }

    getCurrentPageInfo() {
        return this.stack[this.stack.length - 1]
    }
}

const navigation = new Navigation()

class RuntimeManager {
    constructor() {
        this.app = null
        this.pages = new Map()
    }

    createApp(bridgeId, pagePath) {
        if (this.app) {
            return
        }

        const moduleInfo = loader.staticModules.get('appModule')
        this.app = new AppInstance(moduleInfo, {
            pagePath,
        })
    }

    createPage(path, bridgeId, query) {
        const moduleInfo = loader.staticModules.get(path)
        navigation.pushState({
            path,
            bridgeId,
            query,
        })
        console.log("!!!!!", navigation)
        this.pages.set(bridgeId, new PageInstance(moduleInfo, { bridgeId, path, query }))
    }
 
    pageScroll(bridgeId, offsetY) {
        let page = this.pages.get(bridgeId)
        page.onPageScroll && page.onPageScroll({ scrollTop: offsetY })
    }

    triggerEvent(bridgeId, eventName, paramsList) {
        let page = this.pages.get(bridgeId)
        page[eventName] && page[eventName](...paramsList)
    }

    pageReady(bridgeId) {
        const page = this.pages.get(bridgeId);
        page.onReady && page.onReady();
    }
}

const runtimeManager = new RuntimeManager()

class Loader {
    constructor() {
        this.staticModules = new Map()
    }

    loadLogic(appId, bridgeId, pages) {
        NativeAPI.request(`https://weapp-frame.oss-cn-shanghai.aliyuncs.com/${appId}/logic.js`, (res) => {
            eval(res)
            modRequire('app')
            pages.forEach(page => {
                modRequire(page)
            })
            NativeAPI.sendMessage({
                type: 'logicResourceLoaded',
                body: {
                    bridgeId,
                }
            })
        })
    }

    createAppModule(moduleInfo) {
        this.staticModules.set('appModule', moduleInfo)
    }

    createPageModule(pageInfo, compileInfo) {
        this.staticModules.set(compileInfo.path, pageInfo)
    }
}

let loader = new Loader()

function nativeCall(payload) {
    console.log("Native Call:", payload)
    const {
        type,
        body,
    } = payload

    if (type === 'loadResource') {
        const {
            appId,
            bridgeId,
            pages,
        } = body
        loader.loadLogic(appId, bridgeId, pages)
    } else if (type === 'createApp') {
        const {
            bridgeId,
            pagePath,
        } = body
        runtimeManager.createApp(bridgeId, pagePath)
        NativeAPI.sendMessage({
            type: 'appIsCreated',
            body: {
                bridgeId,
            }
        })
    } else if (type === 'makePageInitialData') {
        const {
            bridgeId,
            pagePath,
        } = body
        const initialData = loader.staticModules.get(pagePath)?.data ?? {}
        NativeAPI.sendMessage({
            type: 'initialDataIsReady',
            body: {
                initialData,
                bridgeId,
                pagePath,
            }
        })
    } else if (type === 'createPageInstance') {
        const {
            path,
            bridgeId,
            query
        } = body
        runtimeManager.createPage(path, bridgeId, query)
    } else if (type === 'pageScroll') {
        const {
            bridgeId,
            offsetY,
        } = body
        runtimeManager.pageScroll(bridgeId, offsetY)
    } else if (type === 'triggerEvent') {
        const {
            id,
            methodName,
            paramsList,
        } = body
        runtimeManager.triggerEvent(id, methodName, paramsList)
    } else if (type === 'moduleMounted') {
        const {
            id,
        } = body
        runtimeManager.pageReady(id)
    }
}

//NativeAPI.sendMessage({ type: "来自逻辑线程的消息" })

function App(moduleInfo) {
    loader.createAppModule(moduleInfo)
}

function Page(pageInfo, compileInfo) {
    loader.createPageModule(pageInfo, compileInfo)
}
