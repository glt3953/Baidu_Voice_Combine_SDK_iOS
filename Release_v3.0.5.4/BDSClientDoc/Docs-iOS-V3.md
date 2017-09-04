# 百度语音开放平台-iOS SDK文档

[TOC]

## 1. 概述

本文档是百度语音开放平台iOS SDK的用户指南，描述了**语音识别、长语音识别、语音唤醒**等相关接口的使用说明。

### 1.1 兼容性

| 类别   | 兼容范围                                   |
| ---- | -------------------------------------- |
| 系统   | 支持iOS 6.0及以上系统                         |
| 架构   | armv7、arm64、i386、x86_64（模拟器架构暂不支持离线功能） |
| 网络   | 支持移动网络、WIFI等网络环境                       |
| 开发环境 | 工程内使用了LTO等优化选项，建议使用最新版本Xcode进行开发       |

### 1.2 资源占用描述

静态库占用:

| SDK类型 | 静态库大小 | 二进制增量 | __TEXT增量  |
| ----- | ----- | ----- | --------- |
| 识别+唤醒 | 83.0M | 1.9M  | 1.0M~1.2M |

资源占用：

| 资源名称                     | 资源描述                               | 资源大小    |
| ------------------------ | ---------------------------------- | ------- |
| bds_easr_basic_model.dat | 基础语言模型                             | 2.3M    |
| bds_easr_input_model.dat | 离线识别输入法模式语言模型。如无需使用离线输入法模式，可移除该文件。 | 56.8M   |
| bds_easr_mfe_cmvn.dat    | MFE CMVN文件                         | 690Byte |
| bds_easr_mfe_dnn.dat     | 基础资源文件，用于DNNMFE                    | 39K     |
```
由于 BITCODE 开启会导致二进制文件体积增大，这部分会在 APPStore 发布时进行进一步编译优化，并不会引起最终文件的体积变化，故此处计算的是关闭 BITCODE 下的二进制增量。
```

## 2. 集成

### 2.1 Demo工程

**强烈建议在使用iOS SDK之前，运行并试用Demo工程相关功能，参考Demo工程的调用和配置的方式。**

1. 双击使用XCode打开 BDSClientSample/BDSClientSample.xcodeproj
2. 在 [speech官网](speech.baidu.com)或[AI官网](ai.baidu.com)新建应用，配置应用的BundleId为工程的BundleId，默认为com.baidu.speech.BDSClientSample
3. 修改 BDSClientSample/Modules/ASR/ASRViewController.m中的 API_KEY, SECRET_KEY, APP_ID 
4. 确保网络通畅，运行工程


### 2.1 语音识别&唤醒

#### 2.1.1 添加Framework

| Framework           | 描述                    |
| ------------------- | ----------------------- | 
| libc++.tbd          | 提供对C/C++特性支持            |      
| libz.1.2.5.tbd      | 提供gzip支持                |      
| AudioToolbox        | 提供录音和播放支持               |      
| AVFoundation        | 提供录音和播放支持               |     
| CFNetwork           | 提供对网络访问的支持              |      
| CoreLocation        | 提供对获取设备地理位置的支持，以提高识别准确度 |      
| CoreTelephony       | 提供对移动网络类型判断的支持          |      
| SystemConfiguration | 提供对网络状态检测的支持            |      
| GLKit               | 内置识别控件所需                |      

#### 2.1.2 添加头文件

##### 2.1.2.1 识别相关

如果只需要使用识别功能，只需要引入如下头文件：

```objc
#import "BDSEventManager.h"
#import "BDSASRDefines.h"
#import "BDSASRParameters.h"
```

##### 2.1.2.2 唤醒相关

如果需要使用离线唤醒功能，需要引入如下头文件：

```objc
#import "BDSWakeupDefines.h"
#import "BDSWakeupParameters.h"
```
##### 2.1.2.3 内置识别控件

如果需要使用内置识别控件，需要引入如下头文件：

```objc
#import "BDTheme.h"
#import "BDRecognizerViewParamsObject.h"
#import "BDRecognizerViewController.h"
#import "BDRecognizerViewDelegate.h"
```
#### 2.1.3 添加静态库

SDK提供的是静态库，开发者只需要将库文件拖入工程目录即可。对静态库有以下几点说明：

	1. 静态库采用lipo命令将armv7，arm64及模拟器Debug版的静态库合并成的一个通用的库文件，避免开发者在编译不同target时频繁替换的问题；
	2. 模拟器版本只支持在线识别，不支持离线识别及唤醒功能;

#### 2.1.4 添加所需资源

##### 2.1.4.1 提示音文件及识别控件所需主题文件

将开发包中BDSClientResource/ASR/BDSClientResources目录以“create folder references”方式添加到工程的资源Group中，**注意使用"create groups"方式添加不能生效**。

##### 2.1.4.2 离线识别及唤醒所需资源文件

将开发包中BDSClientResource/ASR/BDSClientEASRResources目录以"create groups"方式添加到工程目录下即可，资源文件说明如下：

| 文件名                           | 说明                              |
| ----------------------------- | ------------------------------- |
| bds_easr_gramm.dat            | 离线识别引擎语法模式所需语法文件，在开放平台编辑自定义语法文件 |
| bds_easr_basic_model.dat      | 基础资源文件，用于modelVAD、唤醒、离线语音识别语法模式 |
| bds_easr_wakeup_words.dat     | 唤醒引擎所需唤醒词文件，在开放平台编辑自定义唤醒词       |
| bds_easr_mfe_dnn.dat          | 基础资源文件，用于DNNMFE、唤醒、离线语音识别语法模式   |
| bds_easr_mfe_cmvn.dat         | MFE CMVN文件,用于DNNMFE             |
| bds_easr_dnn_wakeup_model.dat | 用于DNNWakeup的模型文件                |

## 3. 语音识别

语音识别包含数据上传接口和离在线识别接口，接口概述如下：

	1. 创建相关接口对象 (createEventManagerWithName:)
	2. 设置代理对象 (setDelegate:)
	3. 配置参数 (setParameter:forKey:)
	4. 发送预定义指令 (sendCommand:)
	5. 参数列表及相关预定义值可参考附录，或相关parameters头文件、defines头文件

>  1. 在线语音识别支持识别任意词，离线语音识别仅支持命令词识别（语法模式）。如需使用离线任意词识别功能，请在官网提交商务合作咨询。
>  2. 单次语音识别最长限制60秒。

### 3.1  在线识别

```objc
// 创建语音识别对象
self.asrEventManager = [BDSEventManager createEventManagerWithName:BDS_ASR_NAME];
// 设置语音识别代理
[self.asrEventManager setDelegate:self];
// 参数配置：在线身份验证
[self.asrEventManager setParameter:@[API_KEY, SECRET_KEY] forKey:BDS_ASR_API_SECRET_KEYS];
//设置 APPID
[self.asrEventManager setParameter:APP_ID forKey:BDS_ASR_OFFLINE_APP_CODE];
// 发送指令：启动识别
[self.asrEventManager sendCommand:BDS_ASR_CMD_START];
```

**识别功能代理**

```objc
@protocol BDSClientASRDelegate<NSObject>
- (void)VoiceRecognitionClientWorkStatus:(int)workStatus obj:(id)aObj;
@end
```

语音识别状态、录音数据等回调均在此代理中发生，具体事件请参考Demo工程中对不同workStatus的处理流程。



### 3.2 离在线并行识别

```objc
// 创建语音识别对象
self.asrEventManager = [BDSEventManager createEventManagerWithName:BDS_ASR_NAME];
// 设置语音识别代理
[self.asrEventManager setDelegate:self];
// 参数配置：在线身份验证
[self.asrEventManager setParameter:@[API_KEY, SECRET_KEY] forKey:BDS_ASR_API_SECRET_KEYS];
//设置 APPID
[self.asrEventManager setParameter:APP_ID forKey:BDS_ASR_OFFLINE_APP_CODE];
// 参数设置：识别策略为离在线并行
[self.asrEventManager setParameter:@(EVR_STRATEGY_BOTH) forKey:BDS_ASR_STRATEGY];
// 参数设置：离线识别引擎类型
[self.asrEventManager setParameter:@(EVR_OFFLINE_ENGINE_GRAMMER) forKey:BDS_ASR_OFFLINE_ENGINE_TYPE];
// 参数配置：命令词引擎语法文件路径。 请在 (官网)[http://speech.baidu.com/asr] 参考模板定义语法，下载语法文件后，替换BDS_ASR_OFFLINE_ENGINE_GRAMMER_FILE_PATH参数
[self.asrEventManager setParameter:@"命令词引擎语法文件路径" forKey:BDS_ASR_OFFLINE_ENGINE_GRAMMER_FILE_PATH];
// 参数配置：命令词引擎语言模型文件路径
[self.asrEventManager setParameter:@"命令词引擎语言模型文件路径" forKey:BDS_ASR_OFFLINE_ENGINE_DAT_FILE_PATH];
// 发送指令：加载离线引擎
[self.asrEventManager sendCommand:BDS_ASR_CMD_LOAD_ENGINE];
// 发送指令：启动识别
[self.asrEventManager sendCommand:BDS_ASR_CMD_START];
```

#### 关于离线识别

> 注意
>
> 在线识别效果远优于离线识别，不推荐使用离线识别。
>
> 首次使用离线，SDK将会后台下载离线授权文件，成功后，授权文件有效期（三年）内无需联网。有效期即将结束后SDK将自动多次尝试联网更新证书)。

使用离线识别必须正确配置BDS_ASR_OFFLINE_APP_CODE，并设置BDS_ASR_STRATEGY为离线在线并行。

离线识别 可识别自定义语法规则下的词，如“打电话给张三”，“打开微信”等，可参考http://speech.baidu.com/asr 。
具体示例如下：

```objective-c
NSString* gramm_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_gramm" ofType:@"dat"];;
NSString* lm_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];;
NSString* wakeup_words_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_wakeup_words" ofType:@"dat"];;
[self.asrEventManager setDelegate:self];
[self.asrEventManager setParameter:APP_ID forKey:BDS_ASR_OFFLINE_APP_CODE];
[self.asrEventManager setParameter:lm_filepath forKey:BDS_ASR_OFFLINE_ENGINE_DAT_FILE_PATH];
// 请在 (官网)[http://speech.baidu.com/asr] 参考模板定义语法，下载语法文件后，替换BDS_ASR_OFFLINE_ENGINE_GRAMMER_FILE_PATH参数
[self.asrEventManager setParameter:gramm_filepath forKey:BDS_ASR_OFFLINE_ENGINE_GRAMMER_FILE_PATH];
[self.asrEventManager setParameter:wakeup_words_filepath forKey:BDS_ASR_OFFLINE_ENGINE_WAKEUP_WORDS_FILE_PATH];
```


### 3.3 长语音识别

长语音识别对语音时长无限制，其本质是在本地进行VAD之后，由服务端逐句识别。

```objective-c
[self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_NEED_CACHE_AUDIO];
[self.asrEventManager setParameter:@"" forKey:BDS_ASR_OFFLINE_ENGINE_TRIGGERED_WAKEUP_WORD];
[self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_LONG_SPEECH];
// 长语音请务必开启本地VAD
[self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_LOCAL_VAD];
```

> 1. 使用长语音必须开启本地VAD: BDS_ASR_ENABLE_LOCAL_VAD
> 2. 使用长语音必须关闭提示音（Known issue）



### 3.4 VAD

端点检测，即自动检测音频输入的起始点和结束点，如果需要自行控制识别结束需关闭VAD，请同时关闭服务端VAD与端上VAD：

```objective-c
// 关闭服务端VAD
[self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_ENABLE_EARLY_RETURN];
// 关闭本地VAD
[self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_ENABLE_LOCAL_VAD];
```

目前SDK支持两种本地端点检测方式。说明如下：

| 识别策略     | 说明                  |
| -------- | ------------------- |
| ModelVAD | 检测更加精准，抗噪能力强，响应速度较慢 |
| DNNMFE   | 提供基础检测功能，性能高，响应速度快  |

> 使用ModelVAD、DNN需通过参数配置开启该功能，并配置相应资源文件（基础资源文件）

####  ModelVAD

```objc
//获取VAD模型的路径
NSString *modelVAD_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];
//设置modelVAD的文件路径
[self.asrEventManager setParameter:modelVAD_filepath forKey:BDS_ASR_MODEL_VAD_DAT_FILE];
//设置ModelVAD可用
[self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_MODEL_VAD];
```
####  DNNMFE

```objc
NSString *mfe_dnn_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_mfe_dnn" ofType:@"dat"];
//设置MFE模型文件
[self.asrEventManager setParameter:mfe_dnn_filepath forKey:BDS_ASR_MFE_DNN_DAT_FILE];
NSString *cmvn_dnn_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_mfe_cmvn" ofType:@"dat"];
//设置MFE CMVN文件路径
[self.asrEventManager setParameter:cmvn_dnn_filepath forKey:BDS_ASR_MFE_CMVN_DAT_FILE];
```

DNNMFE 支持设置静音时长。设置以下两个参数，单位为帧数，每帧10ms。如需设置为 5s：

```objc
[self.asrEventManager setParameter:@(501) forKey:BDS_ASR_MFE_MAX_SPEECH_PAUSE];
[self.asrEventManager setParameter:@(500) forKey:BDS_ASR_MFE_MAX_WAIT_DURATION];
```



### 3.5 语义理解

语义解析可以识别用户的意图并提取用户表述中的关键内容，从而帮助开发者理解用户需求。如“北京天气”，“打电话给张三”等。语义理解包括本地语义和在线语义。

目前仅中文普通话支持语义理解。

使用在线语义，必须设置BDS_ASR_PRODUCT_ID为15361，完整的PRODUCT_ID列表请参考章节PRODUCT_ID

```objective-c
// 开启离线语义(本地语义)
[self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_NLU]; 
// 开启在线语义
[self.asrEventManager setParameter:@"15361" forKey:BDS_ASR_PRODUCT_ID];
```

> 注意：BDS_ASR_PRODUCT_ID参数会覆盖识别语言的设置



## 4. 语音唤醒

语音唤醒，需要配置所需**语言模型文件（基础资源文件）**及官网导出的自定义**唤醒词文件**，配置后加载引擎，即可进行开始唤醒。需要注意的是，唤醒引擎开启后会保持录音机为启动状态，用户说出正确的唤醒词后会触发唤醒，通过相关回调反馈给应用程序。

语音唤醒为离线功能，需配置离线授权信息(APP_ID)，加载唤醒所需语言模型文件，接口与语音识别接口相同。

基于多种因素考虑，在App进入后台后，唤醒将会被打断。

### 4.1 代码示例

```objc
// 创建语音识别对象
self.wakeupEventManager = [BDSEventManager createEventManagerWithName:BDS_WAKEUP_NAME];
// 设置语音唤醒代理
[self.wakeupEventManager setDelegate:self];
// 参数配置：离线授权APPID
[self.wakeupEventManager setParameter:APP_ID forKey:BDS_WAKEUP_APP_CODE];
// 参数配置：唤醒语言模型文件路径, 默认文件名为 bds_easr_basic_model.dat
[self.wakeupEventManager setParameter:@"唤醒语言模型文件路径" forKey:BDS_WAKEUP_DAT_FILE_PATH];
// 发送指令：加载语音唤醒引擎
[self.wakeupEventManager sendCommand:BDS_WP_CMD_LOAD_ENGINE];
//设置唤醒词文件路径
// 默认的唤醒词文件为"bds_easr_wakeup_words.dat"，包含的唤醒词为"百度一下"
// 如需自定义唤醒词，请在 http://ai.baidu.com/tech/speech/wake 中评估并下载唤醒词文件，替换此参数
[self.asrEventManager setParameter:@"唤醒词文件路径" forKey:BDS_WAKEUP_WORDS_FIEL_PATH]
// 发送指令：启动唤醒
[self.wakeupEventManager sendCommand:BDS_WP_CMD_START];
```

### 4.2 唤醒功能回调接口

```objc
@protocol BDSClientWakeupDelegate<NSObject>
- (void)WakeupClientWorkStatus:(int)workStatus obj:(id)aObj;
@end
```

### 4.3 唤醒辅助识别
使用唤醒的一种需求场景是唤醒后立刻识别，以唤醒词为**百度一下**举例，用户可能的输入为**百度一下，北京天气怎么样？**如果开发者需要对该种场景进行支持，请按如下操作：

> 1. 正确配置唤醒引擎，语言模型文件及唤醒词文件，并加载引擎；
> 2. 开启唤醒，接收用户语音输入；
> 3. 在唤醒的唤醒词触发回调中，配置BDS_ASR_NEED_CACHE_AUDIO为YES到识别引擎，正常识别请将该值设为NO；
> 4. 调用识别引擎开启识别过程；

```objc
// 如需要唤醒后立刻进行识别，为保证不丢音，启动语音识别前请添加如下配置，获取录音缓存：
[self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_NEED_CACHE_AUDIO];
```

## 5. 功能说明

BDSClientHeaders/ASR/Settings/BDSASRDefines.h 与 BDSASRParameters.h 头文件中包含了绝大多数SDK的可用配置参数及说明。

### 5.1 语音识别音频数据源配置

目前SDK支持三种音频数据源。说明如下：

| 音频数据源 | 优先级  | 说明                  |
| ----- | ---- | ------------------- |
| 文件输入  | 高    | 16K采样率、单声道PCM格式音频文件 |
| 输入流   | 中    | 用以支持外接音源，如车载录音机     |
| 本地录音机 | 低    | 手机设备内置录音功能          |

> 1. 默认使用本地录音机，如设置过文件或输入流相关参数，将其置空即可恢复为默认设置；
> 2. 录音模块运行时，切换数据源不生效；
> 3. 多模块共享录音模块，重复设置会产生覆盖；


### 5.2 语音识别策略

目前SDK支持两种识别策略。说明如下：

| 识别策略 | 说明                    |
| ---- | --------------------- |
| 在线识别 | 识别请求发至语音服务器进行解析       |
| 并行模式 | 离在线识别同时进行，取第一个返回的识别结果 |

### 5.3 引擎验证方法

在线识别与唤醒都需要进行相关验证后方可使用：

| 引擎类型 | 验证方法                             |
| ---- | -------------------------------- |
| 在线识别 | 开放平台使用API/SECRET KEY + APPID进行验证 |
| 离线识别 | 使用APPID进行验证                      |
| 唤醒引擎 | 与离线识别验证方法一致                      |

### 5.4 语音识别中的AudioSession

语音识别SDK默认会将AudioSession的Category设置为AVAudioSessionCategoryPlayAndRecord，并在必要的时候调用setActive接口对外部音频进行打断及恢复，如果开发者不希望SDK对AudioSession进行操作，可以通过参数配置接口，把BDS_ASR_DISABLE_AUDIO_OPERATION对应的value设置为YES，即可屏蔽SDK内部的操作。

需要注意的是，SDK仍会对Category进行设置，只是屏蔽了setActive接口的调用，开发者可根据需求自行配置。


### 5.5 标点输出

如若需要输出标点，请先根据语言设置支持标点的PRODUCT_ID，同时关闭BDS_ASR_DISABLE_PUNCTUATION

```objective-c
// -- 开启标点输出 -----
[self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_DISABLE_PUNCTUATION];
// 普通话标点
[self.asrEventManager setParameter:@"1537" forKey:BDS_ASR_PRODUCT_ID];
// 英文标点
// [self.asrEventManager setParameter:@"1737" forKey:BDS_ASR_PRODUCT_ID];
```


### 5.6 PRODUCT_ID

在线参数， 请根据语言， 长短句模型及是否需要在线语义，来选择PID。
* 语言：目前支持中文普通话，四川话，粤语，和英语四个
* 长句模型：即输入法模型，适用于较长的句子输入。默认有标点，不支持在线语义; 开启标点后，不支持本地语义。
* 短句模型：即搜索模型，适用于较短的句子输入。无标点，支持在线语义和本地语义。
* 在线语义：在线语义只支持普通话（本地语义也是只支持普通话）

| PID   | 语言   | 长短句模型        | 是否有标点 | 在线语义 | 备注   |
| ----- | ---- | ------------ | ----- | :--- | ---- |
| 1536  | 普通话  | 短句模型（即搜索模型）  | 无标点   | 不支持  | 默认   |
| 15361 | 普通话  | 短句模型（即搜索模型）  | 无标点   | 支持   |      |
| 1537  | 普通话  | 长句模型（即输入法模型） | 可以有标点 | 不支持  |      |
| 1736  | 英语   | 短句模型（即搜索模型）  | 无标点   | 不支持  |      |
| 1737  | 英语   | 长句模型（即输入法模型） | 可以有标点 | 不支持  |      |
| 1636  | 粤语   | 短句模型（即搜索模型）  | 无标点   | 不支持  |      |
| 1637  | 粤语   | 长句模型（即输入法模型） | 可以有标点 | 不支持  |      |
| 1836  | 四川话  | 短句模型（即搜索模型）  | 无标点   | 不支持  |      |
| 1837  | 四川话  | 长句模型（即输入法模型） | 可以有标点 | 不支持  |      |

> 以上描述的“长句模型”与“长语音识别”是两个概念



PRODUCT_ID通过参数BDS_ASR_PRODUCT_ID来配置，如

```objective-c
[self.asrEventManager setParameter:@"1537" forKey:BDS_ASR_PRODUCT_ID];
```

> 注意：BDS_ASR_PRODUCT_ID参数会覆盖识别语言的设置





## 6. 附录

### 6.1 语音识别

#### 预定义命令

语音识别目前支持的命令如下：

| 命令                        | 功能描述                        |
| ------------------------- | --------------------------- |
| BDS_ASR_CMD_START         | 启动识别                        |
| BDS_ASR_CMD_STOP          | 结束语音输入，等待识别完成               |
| BDS_ASR_CMD_CANCEL        | 取消本次识别                      |
| BDS_ASR_CMD_LOAD_ENGINE   | 加载离线引擎，如使用离线识别，在启动识别前需调用此命令 |
| BDS_ASR_CMD_UNLOAD_ENGINE | 卸载离线引擎，如改变离线配置参数，需重新加载离线引擎  |

#### 识别状态

语音识别回调状态如下：

| 识别状态                                     | 返回值说明               | 功能描述                         |
| ---------------------------------------- | ------------------- | ---------------------------- |
| EVoiceRecognitionClientWorkStatusStartWorkIng | nil                 | 识别工作开始，开始采集及处理数据             |
| EVoiceRecognitionClientWorkStatusStart   | nil                 | 检测到用户开始说话                    |
| EVoiceRecognitionClientWorkStatusEnd     | nil                 | 本地声音采集结束结束，等待识别结果返回并结束录音     |
| EVoiceRecognitionClientWorkStatusNewRecordData | NSData-原始音频数据       | 录音数据回调                       |
| EVoiceRecognitionClientWorkStatusFlushData | NSDictionary-中间结果   | 连续上屏                         |
| EVoiceRecognitionClientWorkStatusFinish  | NSDictionary-最终识别结果 | 语音识别功能完成，服务器返回正确结果           |
| EVoiceRecognitionClientWorkStatusMeterLevel | NSNumber:int-当前音量   | 当前音量回调                       |
| EVoiceRecognitionClientWorkStatusCancel  | nil                 | 用户取消                         |
| EVoiceRecognitionClientWorkStatusError   | NSError-错误信息        | 发生错误                         |
| EVoiceRecognitionClientWorkStatusLoaded  | nil                 | 离线引擎加载完成                     |
| EVoiceRecognitionClientWorkStatusUnLoaded | nil                 | 离线引擎卸载完成                     |
| EVoiceRecognitionClientWorkStatusChunkThirdData | NSData              | CHUNK: 识别结果中的第三方数据           |
| EVoiceRecognitionClientWorkStatusChunkNlu | NSData              | CHUNK: 识别结果中的语义结果            |
| EVoiceRecognitionClientWorkStatusChunkEnd | NSString            | CHUNK: 识别过程结束                |
| EVoiceRecognitionClientWorkStatusFeedback | NSString            | Feedback: 识别过程反馈的打点数据        |
| EVoiceRecognitionClientWorkStatusRecorderEnd | nil                 | 录音机关闭，页面跳转需检测此时间，规避状态条 (iOS) |
| EVoiceRecognitionClientWorkStatusLongSpeechEnd | nil                 | 长语音结束状态                      |

#### 参数说明

通过配置不同的参数，语音识别提供丰富的功能，说明如下：

##### 1. 在线引擎身份验证

| 参数名称                    | 说明                           |
| ----------------------- | ---------------------------- |
| BDS_ASR_API_SECRET_KEYS | 开放平台设置API_KEY and SECRET_KEY |
| BDS_ASR_PRODUCT_ID      | 内部产品设置产品ID                   |

##### 2. 离线引擎身份验证

| 参数名称                              | 说明                                       |
| --------------------------------- | ---------------------------------------- |
| BDS_ASR_OFFLINE_LICENSE_FILE_PATH | 离线授权文件路径                                 |
| BDS_ASR_OFFLINE_APP_CODE          | 离线授权所需APPCODE（APPID），<br>如使用该方式进行正式授权，请移除临时授权文件 |

##### 3. 识别器参数配置

| 参数名称                          | 说明                                      |
| ----------------------------- | --------------------------------------- |
| BDS_ASR_SAMPLE_RATE           | 设置录音采样率，自动模式根据当前网络情况自行调整                |
| BDS_ASR_STRATEGY              | 语音识别策略                                  |
| BDS_ASR_LANGUAGE              | 设置识别语言                                  |
| BDS_ASR_ENABLE_NLU            | 开启语义解析，将返回包含语义的json串                    |
| BDS_ASR_DISABLE_PUNCTUATION   | 关闭输出标点                                  |
| BDS_ASR_ENABLE_LOCAL_VAD      | 是否需要对录音数据进行端点检测，如果关闭，请同时关闭服务端提前返回       |
| BDS_ASR_ENABLE_EARLY_RETURN   | 服务端开启提前返回，即允许服务端在未收到客户端发送的结束标志前提前结束识别过程 |
| BDS_ASR_ENABLE_MODEL_VAD      | 是否使用ModelVAD，打开需配置资源文件参数                |
| BDS_ASR_MODEL_VAD_DAT_FILE    | ModelVAD所需资源文件路径                        |
| BDS_ASR_VAD_ENABLE_LONG_PRESS | 设置VAD模式为长按（特殊情况设置）                      |
| BDS_ASR_MFE_DNN_DAT_FILE      | 设置MFE模型文件                               |
| BDS_ASR_MFE_CMVN_DAT_FILE     | 设置MFE CMVN文件路径                          |
| BDS_ASR_MFE_MAX_WAIT_DURATION | 设置DNNMFE最大等待语音时间                        |
| BDS_ASR_MFE_MAX_SPEECH_PAUSE  | 设置DNNMFE切分门限                            |
| BDS_ASR_ENABLE_LONG_SPEECH    | 是否启用长语音识别                               |

##### 4. 音频相关

| 参数名称                            | 说明                             |
| ------------------------------- | ------------------------------ |
| BDS_ASR_AUDIO_FILE_PATH         | 设置音频文件路径（数据源）                  |
| BDS_ASR_AUDIO_INPUT_STREAM      | 设置音频输入流（数据源）                   |
| BDS_ASR_PLAY_TONE               | 识别提示音设置，需添加相应声音文件，可替换          |
| BDS_ASR_DISABLE_AUDIO_OPERATION | 屏蔽SDK内部设置AudioSession的Active状态 |

##### 5. 日志级别

| 参数名称                    | 说明       |
| ----------------------- | -------- |
| BDS_ASR_DEBUG_LOG_LEVEL | 指定调试日志级别 |

##### 6. 离线识别相关

| 参数名称                                     | 说明                      |
| ---------------------------------------- | ----------------------- |
| BDS_ASR_OFFLINE_ENGINE_TYPE              | 离线识别引擎类型                |
| BDS_ASR_OFFLINE_ENGINE_DAT_FILE_PATH     | 离线识别资源文件路径              |
| BDS_ASR_OFFLINE_ENGINE_GRAMMER_FILE_PATH | 离线识别语法文件路径              |
| BDS_ASR_OFFLINE_ENGINE_GRAMMER_SLOT      | 语法模式离线语法槽，使用该参数更新离线语法文件 |

##### 7. 唤醒后立刻识别相关

| 参数名称                                     | 说明                                       |
| ---------------------------------------- | ---------------------------------------- |
| BDS_ASR_OFFLINE_ENGINE_WAKEUP_WORDS_FILE_PATH | 唤醒词文件路径，使用了唤醒并使用离线语法识别的情况下需要设置，其他情况请忽略该参数 |
| BDS_ASR_OFFLINE_ENGINE_TRIGGERED_WAKEUP_WORD | 当前触发唤醒词，唤醒后立即调用识别的情况下配置，其他情况请忽略该参数       |
| BDS_ASR_NEED_CACHE_AUDIO                 | 唤醒后立刻进行识别需开启该参数，其他情况请忽略该参数               |

##### 8. 服务端配置相关

| 参数名称                       | 说明                                       |
| -------------------------- | ---------------------------------------- |
| BDS_ASR_SERVER_URL         | 设置服务器地址                                  |
| BDS_ASR_BROWSER_USER_AGENT | 设置浏览器标识(Http request header)，资源返回时会根据UA适配 |

### 6.2 语音唤醒

#### 预定义命令

语音唤醒目前支持的命令如下：

| 命令                       | 功能描述                  |
| ------------------------ | --------------------- |
| BDS_WP_CMD_START         | 启动唤醒                  |
| BDS_WP_CMD_STOP          | 关闭唤醒，释放内存需调用卸载命令      |
| BDS_WP_CMD_LOAD_ENGINE   | 加载唤醒引擎                |
| BDS_WP_CMD_UNLOAD_ENGINE | 卸载唤醒引擎，如改变了引擎参数，请重新加载 |

#### 唤醒状态

| 唤醒状态                             | 返回值说明        | 功能描述     |
| -------------------------------- | ------------ | -------- |
| EWakeupEngineWorkStatusStarted   | nil          | 引擎开始工作   |
| EWakeupEngineWorkStatusStopped   | nil          | 引擎关闭完成   |
| EWakeupEngineWorkStatusLoaded    | nil          | 唤醒引擎加载完成 |
| EWakeupEngineWorkStatusUnLoaded  | nil          | 唤醒引擎卸载完成 |
| EWakeupEngineWorkStatusTriggered | NSString-唤醒词 | 命中唤醒词    |
| EWakeupEngineWorkStatusError     | NSError-错误信息 | 引擎发生错误   |

#### 参数说明

为使唤醒引擎正常工作，开发者需了解以下参数：

##### 1. 基本配置

| 参数名称                         | 说明                     |
| ---------------------------- | ---------------------- |
| BDS_WAKEUP_WORDS_FILE_PATH   | 唤醒词文件路径，从开放平台获取该文件     |
| BDS_WAKEUP_DAT_FILE_PATH     | 唤醒引擎模型文件路径             |
| BDS_WAKEUP_APP_CODE          | 离线正式授权所需APPCODE，即APPID |
| BDS_WAKEUP_LICENSE_FILE_PATH | 离线授权文件路径，正式授权需移除该文件    |
| BDS_WAKEUP_WORK_QUEUE        | 指定SDK工作队列              |

##### 2. 音频相关

音频相关的参数与识别引擎共享，如同时使用，只需配置一次

| 参数名称                               | 说明                             |
| ---------------------------------- | ------------------------------ |
| BDS_WAKEUP_AUDIO_FILE_PATH         | 设置音频文件路径（数据源）                  |
| BDS_WAKEUP_AUDIO_INPUT_STREAM      | 设置音频输入流（数据源）                   |
| BDS_WAKEUP_DISABLE_AUDIO_OPERATION | 屏蔽SDK内部设置AudioSession的Active状态 |

#### 错误码说明

##### 1 识别过程中服务器返回错误状态:

| 错误码   | 说明             |
| ----- | -------------- |
| -3001 | 协议参数错误         |
| -3002 | 识别过程出错         |
| -3003 | 没有找到匹配结果       |
| -3004 | PID设置错误        |
| -3005 | 声音质量不符合要求      |
| -3006 | 语音录入过长，请勿超过60s |

##### 2 离线引擎错误状态:

| 错误码     | 说明                                       |
| ------- | ---------------------------------------- |
| 2228230 | dat模型文件不可用，请设置 BDS_ASR_OFFLINE_ENGINE_DAT_FILE_PATH |
| 2228231 | grammar文件无效 ，请设置 BDS_ASR_OFFLINE_ENGINE_GRAMMER_FILE_PATH |
| 2228236 | 识别失败，无法识别。(语法模式下，可能为语音不在自定义的语法规则之下)      |
| 2228226 | [KWS] no license. 首次使用离线引擎请联网，并配置正确的app_id BDS_ASR_OFFLINE_APP_CODE, 绑定BundleId |
|2225219 |server speech quality problem。音频质量过低，无法识别。|


##### 3 录音设备错误状态

| 错误码    | 说明      |
| ------ | ------- |
| 655361 | 录音设备异常  |
| 655362 | 无录音权限   |
| 655363 | 录音设备不可用 |
| 655364 | 录音中断    |

##### 4 网络错误状态

| 错误码     | 说明     |
| ------- | ------ |
| 1966081 | 网络意外出错 |
| 1966082 | 网络不可用  |
| 2031617 | 网络请求超时 |

## FAQ
 * 一句话说完后，如何控制不自动识别？
 关闭VAD即可
 

## Release Notes

版本号： 3.0.5.4，更新内容如下：
 1.新增长语音识别
 2.补全语音唤醒功能
 3.在线语音识别传输协议升级
 4.优化鉴权方案
 5.代码重构，结构调整