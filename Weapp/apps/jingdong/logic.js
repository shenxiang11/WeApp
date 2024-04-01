
			modDefine('pages/home/index', function(require, module, exports) {
				Page({
  data: {
    text: "京东首页"
  },
  onLoad: function (options) {
    // 页面创建时执行
    console.log('京东首页 page onLoad: ', options);
  },
  onShow: function () {
    // 页面出现在前台时执行
    console.log('京东首页 page onShow');
  },
  onReady: function () {
    // 页面首次渲染完毕时执行
    console.log('京东首页 page onReady');
  },
  onHide: function () {
    // 页面从前台变为后台时执行
  },
  onUnload: function () {
    // 页面销毁时执行
  },
  onPageScroll: function (opts) {
    // 页面滚动时执行
    console.log(opts);
  },
  tapHandler(params) {
    this.setData({
      text: this.data.text + '!'
    });
  },
  goDetail() {
    wx.navigateTo({
      url: 'pages/detail/index?a=1&b=2'
    });
  }
}, {
  path: 'pages/home/index'
});
			});
		
			modDefine('pages/detail/index', function(require, module, exports) {
				Page({
  data: {
    text: "退出detail页面"
  },
  onLoad: function (options) {
    // 页面创建时执行
    console.log('京东详情页 page onLoad: ', options);
  },
  onShow: function () {
    // 页面出现在前台时执行
    console.log('京东详情页 page onShow');
  },
  onReady: function () {
    // 页面首次渲染完毕时执行
    console.log('京东详情页 page onReady');
  },
  onHide: function () {
    // 页面从前台变为后台时执行
  },
  onUnload: function () {
    // 页面销毁时执行
  },
  onPageScroll: function () {
    // 页面滚动时执行
  },
  exit() {
    wx.navigateBack({
      delta: 1
    });
  }
}, {
  path: 'pages/detail/index'
});
			});
		
			modDefine('app', function(require, module, exports) {
				App({
  onLaunch(options) {
    console.log('京东APP onLaunch: ', options);
  },
  onShow(options) {
    console.log('京东APP onShow: ', options);
  },
  onHide() {
    console.log('京东APP onHide');
  },
  globalData: 'I am global data'
});
			});
		
