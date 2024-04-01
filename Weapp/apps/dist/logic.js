
			modDefine('pages/home/index', function(require, module, exports) {
				Page({
  data: {
    currentPlayId: '',
    videoList: [{
      id: 'video1',
      url: '//miniapp.ai-matrix.vip/lib/zhuzhu.mp4',
      poster: '//miniapp.ai-matrix.vip/lib/poster.jpg',
      status: 'ready',
      detail: {
        user_photo: '//miniapp.ai-matrix.vip/lib/user-zhu.jpg',
        user_name: '好端端的猪',
        user_id: 'zhuzhu',
        marked: false,
        liked: false,
        like_count: 5732,
        comment_count: 3231,
        mark_count: 2400,
        relay: 4410,
        music_photo: '//miniapp.ai-matrix.vip/lib/user-zhu.jpg',
        description: {
          body: '猪场消毒3.0 #养猪人的日常生活'
        }
      }
    }, {
      id: 'video2',
      url: '//miniapp.ai-matrix.vip/lib/333.mp4',
      poster: '//miniapp.ai-matrix.vip/lib/333.jpg',
      status: 'ready',
      detail: {
        user_photo: '//miniapp.ai-matrix.vip/lib/dancer.jpg',
        user_name: 'FERNWANG',
        user_id: 'dancer',
        marked: false,
        liked: false,
        like_count: '210.2万',
        comment_count: '6.9万',
        mark_count: '8.0万',
        relay: '10.4万',
        music_photo: '//miniapp.ai-matrix.vip/lib/dancer.jpg',
        description: {
          body: '没想到我的舞伴是个女孩子吧 @唱姐 #金大铭编舞 #troublemaker'
        }
      }
    }, {
      id: 'video3',
      url: '//miniapp.ai-matrix.vip/lib/111.mp4',
      poster: '//miniapp.ai-matrix.vip/lib/111.jpg',
      status: 'ready',
      detail: {
        user_photo: '//miniapp.ai-matrix.vip/lib/y.jpg',
        user_name: '不理理-',
        user_id: 'bll',
        marked: false,
        liked: false,
        like_count: '2731',
        comment_count: '205',
        mark_count: '149',
        relay: '113',
        music_photo: '//miniapp.ai-matrix.vip/lib/y.jpg',
        description: {
          sub: {
            type: 'shoping',
            first_title: '购物',
            content: '心动穿搭',
            shop_id: 'S99337552830736'
          },
          body: '这就是男朋友买衣服的审美 #休闲减龄穿搭'
        }
      }
    }, {
      id: 'video4',
      url: '//miniapp.ai-matrix.vip/lib/888.mp4',
      poster: '//miniapp.ai-matrix.vip/lib/888.jpg',
      status: 'ready',
      detail: {
        user_photo: '//miniapp.ai-matrix.vip/lib/xie.jpg',
        user_name: '锋味',
        user_id: 'xie',
        marked: false,
        liked: false,
        like_count: '78.0万',
        comment_count: '3.8万',
        mark_count: '1.2万',
        relay: '8.7万',
        music_photo: '//miniapp.ai-matrix.vip/lib/xie.jpg',
        description: {
          sub: {
            type: 'location',
            first_title: '武侯区',
            content: '何坪舅舅街市火锅',
            shop_id: 'S993375528ue99'
          },
          body: '第14集 | #谢霆锋探店 火锅加碗糯米粉，巴适得板😂 #星河计划'
        }
      }
    }]
  },
  onLoad: function (options) {
    // 页面创建时执行
    console.log('抖音首页 page onLoad: ', options);
  },
  onShow: function () {
    // 页面出现在前台时执行
    console.log('抖音首页 page onShow');
    if (!this.data.currentPlayId) {
      return;
    }
    const currentVideoCtx = wx.createVideoContext(this.data.currentPlayId);
    currentVideoCtx.play();
  },
  onReady: function () {
    // 页面首次渲染完毕时执行
    console.log('抖音首页 page onReady');
    this.playTheFirstVideo();
  },
  onHide: function () {
    // 页面从前台变为后台时执行
    console.log('抖音首页 onHide');
    if (!this.data.currentPlayId) {
      return;
    }
    const currentVideoCtx = wx.createVideoContext(this.data.currentPlayId);
    currentVideoCtx.pause();
  },
  onUnload: function () {
    // 页面销毁时执行
  },
  onPageScroll: function (opts) {
    // 页面滚动时执行
    console.log('抖音首页scroll:', opts);
  },
  playTheFirstVideo() {
    const theFirstVideoData = this.data.videoList[0];
    const videoCtx = wx.createVideoContext(theFirstVideoData.id);
    const newList = this.data.videoList.map(item => {
      if (item.id === theFirstVideoData.id) {
        return {
          ...item,
          status: 'play'
        };
      }
      return {
        ...item
      };
    });
    this.setData({
      currentPlayId: theFirstVideoData.id,
      videoList: newList
    });
    videoCtx.play();
  },
  tapVideo(itemInfo) {
    const {
      id,
      status
    } = itemInfo;
    const videoCtx = wx.createVideoContext(id);
    const newList = this.data.videoList.map(info => {
      if (info.id === id) {
        return {
          ...info,
          status: info.status === 'play' ? 'pause' : 'play'
        };
      }
      return {
        ...info
      };
    });
    this.setData({
      videoList: newList
    });
    status === 'play' ? videoCtx.pause() : videoCtx.play();
  },
  switchVideo(e) {
    const {
      current
    } = e.detail;
    const preVideoCtx = wx.createVideoContext(this.data.currentPlayId);
    const nextVideoCtx = wx.createVideoContext(this.data.videoList[current].id);
    const newList = this.data.videoList.map(info => {
      if (info.id === this.data.currentPlayId) {
        return {
          ...info,
          status: 'ready'
        };
      }
      if (info.id === this.data.videoList[current].id) {
        return {
          ...info,
          status: 'play'
        };
      }
      return {
        ...info
      };
    });
    this.setData({
      currentPlayId: this.data.videoList[current].id,
      videoList: newList
    });
    preVideoCtx.pause();
    nextVideoCtx.play();
  },
  tapLike(e) {
    const {
      id
    } = e.currentTarget.dataset.item;
    const newList = this.data.videoList.map(info => {
      if (info.id !== id) {
        return info;
      }
      return {
        ...info,
        detail: {
          ...info.detail,
          liked: !info.detail.liked
        }
      };
    });
    this.setData({
      videoList: newList
    });
  },
  tapMark(e) {
    const {
      id,
      detail
    } = e.currentTarget.dataset.item;
    const newList = this.data.videoList.map(info => {
      if (info.id !== id) {
        return info;
      }
      return {
        ...info,
        detail: {
          ...info.detail,
          marked: !info.detail.marked
        }
      };
    });
    if (!detail.marked) {
      wx.showToast({
        title: '收藏成功',
        icon: 'success',
        duration: 2000
      });
    } else {
      wx.showToast({
        title: '已取消收藏',
        icon: 'success',
        duration: 2000
      });
    }
    this.setData({
      videoList: newList
    });
  },
  openApp(e) {
    const {
      type,
      shop_id
    } = e.currentTarget.dataset.openInfo;
    if (type === 'shoping') {
      wx.navigateToMiniProgram({
        appId: 'jingdong',
        path: `/pages/home/index?shop_id=${shop_id}`
      });
    }
    if (type === 'location') {
      wx.navigateToMiniProgram({
        appId: 'meituan',
        path: `/pages/home/index?shop_id=${shop_id}`
      });
    }
  },
  openUserPage(e) {
    const {
      userId
    } = e.currentTarget.dataset;
    wx.navigateTo({
      url: `/pages/detail/index?user_id=${userId}`
    });
  }
}, {
  path: 'pages/home/index'
});
			});
		
			modDefine('utils/util', function(require, module, exports) {
				function sum(a, b) {
  return a + b;
}
function uuid(len = 10) {
  let result = '';
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  for (var i = 0; i < len; i++) {
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  return result;
}
const userInfo = {
  zhuzhu: {
    bg: '//miniapp.ai-matrix.vip/lib/zhuzhu_bg.jpg',
    user_photo: '//miniapp.ai-matrix.vip/lib/user-zhu.jpg',
    user_name: '好端端的猪',
    dy_number: '7386837930',
    like: '2401.9万',
    sub: '2',
    fans: '271.6万'
  },
  dancer: {
    bg: '//miniapp.ai-matrix.vip/lib/dancer_bg.jpg',
    user_photo: '//miniapp.ai-matrix.vip/lib/dancer.jpg',
    user_name: 'FERNWANG',
    dy_number: '5383937930',
    like: '1.3亿',
    sub: '311',
    fans: '765.2万'
  },
  bll: {
    bg: '//miniapp.ai-matrix.vip/lib/shop_bg.jpg',
    user_photo: '//miniapp.ai-matrix.vip/lib/y.jpg',
    user_name: '不理理-',
    dy_number: '5583937930',
    like: '166.4万',
    sub: '237',
    fans: '94.1万'
  },
  xie: {
    bg: '//miniapp.ai-matrix.vip/lib/x_bg.jpg',
    user_photo: '//miniapp.ai-matrix.vip/lib/xie.jpg',
    user_name: '锋味',
    dy_number: '2283937930',
    like: '5973.6万',
    sub: '20',
    fans: '948.8万'
  }
};
function getUserData(userId) {
  return userInfo[userId];
}
module.exports = {
  sum,
  uuid,
  getUserData
};
			});
		
			modDefine('pages/detail/index', function(require, module, exports) {
				const {
  getUserData
} = require('utils/util');
Page({
  data: {
    userData: null
  },
  onLoad: function (options) {
    // 页面创建时执行
    console.log('详情页 page onLoad: ', options);
    const {
      user_id
    } = options;
    this.fetchUserDetailInfo(user_id);
  },
  onShow: function () {
    // 页面出现在前台时执行
    console.log('详情页 page onShow');
  },
  onReady: function () {
    // 页面首次渲染完毕时执行
    console.log('详情页 page onReady');
  },
  onHide: function () {
    // 页面从前台变为后台时执行
    console.log('详情页 onHide');
  },
  onUnload: function () {
    // 页面销毁时执行
    console.log('详情页 onUnload');
  },
  onPageScroll: function (opts) {
    // 页面滚动时执行
    console.log(opts);
  },
  goBack() {
    wx.navigateBack({});
  },
  fetchUserDetailInfo(userId) {
    const userData = getUserData(userId);
    this.setData({
      userData
    });
  }
}, {
  path: 'pages/detail/index'
});
			});
		
			modDefine('app', function(require, module, exports) {
				App({
  onLaunch(options) {
    console.log('抖音 onLaunch: ', options);
  },
  onShow(options) {
    console.log('抖音 onShow: ', options);
  },
  onHide() {
    console.log('抖音 onHide');
  },
  globalData: 'I am global data'
});
			});
		