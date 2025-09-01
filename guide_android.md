
# tnk flutter plugin 설치 안내

Tnk의 SDK를 적용하여 게시앱을 구현하는 것은 크게 3단계로 이루어집니다.

1) Tnk 사이트에서 앱 등록 및 매체 정보 등록

2) 앱 내에 Tnk 충전소로 이동하는 버튼 구현

3) 사용자가 충전한 포인트 조회 및 사용

## 앱 등록 및 매체 정보 등록 

다음 절차에 따라 회원 가입 후 광고 매체를 등록합니다.

[1. 회원가입](https://tnkfactory.github.io/docs/join)

[2. 매체 등록 및 app id발급방법](https://tnkfactory.github.io/incentive/APP%20ID)


## Installation

프로젝트의 IDE루트 경로에서 터미널을 열고 다음과 같이 실행하여 플러그인을 설치합니다.

```
flutter pub add tnk_flutter_rwd
```


### Manifest 설정하기

android 프로젝트의 manifest파일에 다음과 같은 설정이 필요합니다.

#### 권한 설정

아래와 같이 권한 사용을 추가합니다.
```xml
// 인터넷
<uses-permission android:name="android.permission.INTERNET" />
// 동영상 광고 재생을 위한 wifi접근
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
// 광고 아이디 획득
<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
```

#### Application ID 설정하기

Tnk 사이트에서 앱 등록하면 상단에 App ID 가 나타납니다. 이를 AndroidMenifest.xml 파일의 application tag 안에 아래와 같이 설정합니다.
(*your-application-id-from-tnk-site* 부분을 실제 App ID 값으로 변경하세요.)


```xml
<application>

    <meta-data android:name="tnkad_app_id" android:value="your-application-id-from-tnk-site" />

</application>
```


#### 적용 예제 샘플입니다.
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.tnkfactory.tnkofferer">
   <application
        android:label="yyyy"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- Specifies an Android theme to apply to this Activity as soon as
                 the Android process has started. This theme is visible to the user
                 while the Flutter UI initializes. After that, this theme continues
                 to determine the Window background behind the Flutter UI. -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
       <meta-data android:name="tnkad_app_id" android:value="3040807040519322223915040708030f" />
    </application>
</manifest>
```


### 라이브러리 등록
TNK SDK는 Maven Central에 배포되어 있습니다.

프로젝트 파일 내에 {projectroot}/android/build.gradle 파일이 있습니다.

build.gradle에 아래와 같이 https://repository.tnkad.net:8443/repository/public/ 를 추가해 주시기 바랍니다.

**예시**
```gradle
buildscript {
    ext.kotlin_version = '2.1.0'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.1.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url "https://jitpack.io" }
        maven { url "https://repository.tnkad.net:8443/repository/public/" }
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
```

### Proguard 사용

Proguard를 사용하실 경우 Proguard 설정내에 아래 내용을 반드시 넣어주세요.

```
-keep class com.tnkfactory.** { *;}
```


위와같은 과정을 마치고 나면 플러터 프로젝트에서 광고 페이지를 호출 하실 수 있습니다.


### 가. 광고 목록 띄우기

<u>테스트 상태에서는 테스트하는 장비를 개발 장비로 등록하셔야 광고목록이 정상적으로 나타납니다.</u>

[테스트 단말기 등록하는 방법](https://tnkfactory.github.io/incentive/reg_test_device)

다음과 같이 호출하여 광고 목록을 출력 하실 수 있습니다.

```dart
// tnk rwd sdk를  import 합니다.
import 'package:tnk_flutter_rwd/tnk_flutter_rwd.dart';

// ...
// ...

class _MyAppState extends State<MyApp> {
  final _tnkFlutterRwdPlugin = TnkFlutterRwd();

  Future<void> showAdList() async {
      await _tnkFlutterRwdPlugin.showATTPopup();  // android에서는 해당 함수는 아무 동작도 하지 않습니다. ios를 위해 호출 할 필요가 있습니다.
      await _tnkFlutterRwdPlugin.setUserName("testUser");
      await _tnkFlutterRwdPlugin.showAdList("타이틀");
  }
  // ...
  // ...
  // ...
  
  // 버튼 구현
  OutlinedButton( onPressed: (){ showAdList(); },
    style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
    child: const Text('show adlist'),
    ) // OutlineButton
  
  // ...
}
```

#### 유저 식별 값 설정

앱이 실행되면 우선 앱 내에서 사용자를 식별하는 고유한 ID를 아래의 API를 사용하시어 Tnk SDK에 설정하시기 바랍니다. 

사용자 식별 값으로는 게임의 로그인 ID 등을 사용하시면 되며, 적당한 값이 없으신 경우에는 Device ID 값 등을 사용할 수 있습니다.

(유저 식별 값이 Device ID 나 전화번호, 이메일 등 개인 정보에 해당되는 경우에는 암호화하여 설정해주시기 바랍니다.) 

유저 식별 값을 설정하셔야 이후 사용자가 적립한 포인트를 개발사의 서버로 전달하는 callback 호출 시에  같이 전달받으실 수 있습니다.

##### Method

- String setUserName(String user_name)

##### Parameters

| 파라메터 명칭 | 내용                                                         |
| ------------- | ------------------------------------------------------------ |
| user_name      | 앱에서 사용자를 식별하기 위하여 사용하는 고유 ID 값 (로그인 ID 등)<br/>길이는 256 bytes 이하입니다. |

##### 적용예시

```dart
TnkFlutterRwd().setUserName("ce3dase0dced3df3as247833")
```

#### showAdList

자신의 앱에서 광고 목록을 띄우기 위하여 TnkSession 객체의 showAdListAsModel:title 또는 showAdListNavigation:title 함수를 사용합니다.
모달뷰 형태로 광고 목록을 띄워주거나 네비게이션 컨트롤러 방식으로 목록을 띄워줍니다.

##### Method

- String showAdList(String title)

##### Description

TnkSession 클래스가 제공하는 메소드로서 광고 목록 화면을 띄워줍니다.

##### Parameters

| 파라메터 명칭  | 내용                          |
| -------------- | ----------------------------- |
| title          | 광고 리스트의 타이틀을 지정함 |


##### 적용예시

```dart
TnkFlutterRwd().showAdList("무료 충전소"];
```

#### adDetail

광고 상세 화면 출력(상세 없는 타입도 상세화면 출력)

##### Method

- String presentAdDetailView(int appId)


##### Parameters

| 파라메터 명칭  | 내용                          |
| -------------- | ----------------------------- |
| appId          | 광고 ID |
| actionId          | default 0 |


##### 적용예시

```dart
TnkFlutterRwd().presentAdDetailView(appId];
```

#### adJoin

광고 참여(상세화면의 참여버튼 효과)

##### Method

- String adJoin(int appId)


##### Parameters

| 파라메터 명칭  | 내용                          |
| -------------- | ----------------------------- |
| appId          | 광고 ID |
| actionId          | default 0 |


##### 적용예시

```dart
TnkFlutterRwd().adJoin(appId];
```

#### adAction

광고 타입에 따라 참여 or 상세 호출

##### Method

- String adAction(int appId)


##### Parameters

| 파라메터 명칭  | 내용                          |
| -------------- | ----------------------------- |
| appId          | 광고 ID |
| actionId          | default 0 |


##### 적용예시

```dart
TnkFlutterRwd().adAction(appId];
```

### 나. 포인트 조회 및 인출

사용자가 광고참여를 통하여 획득한 포인트는 Tnk서버에서 관리되거나 앱의 자체서버에서 관리될 수 있습니다.
포인트가 Tnk 서버에서 관리되는 경우에는 다음의 포인트 조회 및 인출 API를 사용하시어 필요한 아이템 구매 기능을 구현하실 수 있습니다.

#### 현재적립가능한 포인트 조회 

##### Method

- Int getEarnPoint()

##### Description

Tnk서버에서 사용자가 참여 가능한 모든 광고의 적립 가능한 총 포인트 값을 조회하여 그 결과를 long 값으로 반환됩니다.

##### 적용예시
```dart
TnkFlutterRwd().getEarnPoint()
```

#### 사용자 포인트 조회

##### Method

- Int getQueryPoint()

##### Description

Tnk 서버에 적립되어 있는 사용자 포인트 값을 조회합니다.

##### 적용예시
```dart
TnkFlutterRwd().getQueryPoint()
```

#### 포인트 인출 

##### Method

- String purchaseItem(String itemId, int cost)

##### Description

Tnk 서버에 적립되어 있는 사용자 포인트를 차감합니다. 차감내역은 Tnk사이트의 보고서 페이지에서 조회하실 수 있습니다.

##### Parameters

| 파라메터 명칭 | 내용                                                         |
| ------------- | ------------------------------------------------------------ |
| item_id      | 구매할 아이템의 고유ID(게시앱에서 정하여 부여한 ID) Tnk 사이트의 보고서 페이지에서 함께 보여줍니다.|
| cost      | 차감할 포인트 |

##### 적용예시
```dart
TnkFlutterRwd().purchaseItem("item.0001", 10)
```

##### Method

- String withdrawPoints(String description)

##### Description

Tnk 서버에 적립되어 있는 사용자의 모든 포인트를 차감합니다. 차감내역은 Tnk사이트의 보고서 페이지에서 조회하실 수 있습니다.

##### Parameters

| 파라메터 명칭 | 내용                                                         |
| ------------- | ------------------------------------------------------------ |
| description      | 인출과 관련된 설명 등을 넣어줍니다. Tnk 사이트의 보고서 페이지에서 함께 보여줍니다.|

##### 적용예시
```dart
TnkFlutterRwd().withdrawPoints("포인트 전체 인출")
```




### 다. 오퍼월 커스터마이징 

1. 오퍼월 진입시 개인정보 수집 동의 모달창을 비활성화할 수 있습니다.
2. 오퍼월에서 노출되는 포인트 아이콘의 노출을 비활성화할 수 있습니다.

* showAdList() 함수 호출전 호출해야합니다.

##### Method

- setNoUsePointIcon() 

##### 적용예시
```dart
TnkFlutterRwd().setNoUsePointIcon()    // 포인트아이콘 비활성화 
```

##### Method

- setNoUsePrivacyAlert()

##### 적용예시
```dart
TnkFlutterRwd().setNoUsePrivacyAlert()    // 개인정보수집 비활성화
```


---
## 포인트 관리

### Callback URL

사용자가 광고참여를 통하여 획득한 포인트를 개발사의 서버에서 관리하실 경우 다음과 같이 진행합니다.

* 매체 정보 설정 화면에서 아래와 같이 '포인트 관리' 항목을 '자체서버에서 관리'로 선택합니다.
* URL 항목에 포인트 적립 정보를 받을 URL을 입력합니다.

이후에는 사용자에게 포인트가 적립될 때 마다 실시간으로 위 URL로 적립 정보를 받을 수 있습니다.

![RedStyle_08](https://github.com/tnkfactory/ios-sdk-rwd/blob/master/img/callback_setting.jpg)

##### 호출방식

HTTP POST

##### Parameters

| 파라메터   | 상세 내용                                                    | 최대길이 |
| ---------- | ------------------------------------------------------------ |---- |
| seq_id     | 포인트 지급에 대한 고유한 ID 값이다. URL이 반복적으로 호출되더라도 이 값을 사용하여 중복지급여부를 확인할 수 있다. | string(50) |
| pay_pnt    | 사용자에게 지급되어야 할 포인트 값이다.                      | long |
| md_user_nm | 게시앱에서 사용자 식별을 하기 위하여 전달되는 값이다. 이 값을 받기 위해서는 매체앱내에서 setUserName() API를 사용하여 사용자 식별 값을 설정하여야 한다. | string(256) |
| md_chk     | 전달된 값이 유효한지 여부를 판단하기 위하여 제공된다. 이 값은 app_key + md_user_nm + seq_id 의 MD5 Hash 값이다. app_key 값은 앱 등록시 부여된 값으로 Tnk 사이트에서 확인할 수 있다. | string(32) |
| app_id     | 사용자가 참여한 광고앱의 고유 ID 값이다.                     | long |
| pay_dt     | 포인트 지급시각이다. (System milliseconds) 예) 1577343412017 | long |
| app_nm     | 참여한 광고명 이다.                                          |  string(120) |
|pay\_amt|정산되는 금액.|long|
|actn\_id|<p>- 0 : 설치형</p><p>- 1 : 실행형</p><p>- 2 : 액션형</p><p>- 5 : 구매형</p>|int|

##### 리턴값 처리

Tnk 서버에서는 위 URL을 호출하고 HTTP 리턴코드로 200이 리턴되면 정상적으로 처리되었다고 판단합니다. 
만약 200이 아닌 값이 리턴된다면 Tnk 서버는 비정상처리로 판단하고 이후에는 5분 단위 및 1시간 단위로 최대 24시간 동안 반복적으로 호출합니다.

* 중요! 동일한 Request가 반복적으로 호출될 수 있으므로 seq_id 값을 사용하시어 반드시 중복체크를 하셔야합니다.



##### Callback URL 구현 예시 (Java)

```java
// 해당 사용자에게 지급되는 포인트

int payPoint = Integer.parseInt(request.getParameter("pay_pnt"));

// tnk 내부에서 생성한 고유 번호로 이 거래에 대한 Id이다.

String seqId = request.getParameter("seq_id");

// 전달된 파라메터가 유효한지 여부를 판단하기 위하여 사용한다. (아래 코딩 참고)

String checkCode = request.getParameter("md_chk");

// 게시앱에서 사용자 구분을 위하여 사용하는 값(전화번호나 로그인 ID 등)을 앱에서 TnkSession.setUserName()으로 설정한 후 받도록한다.

String mdUserName = request.getParameter("md_user_nm");

// 앱 등록시 부여된 app_key (tnk 사이트에서 확인가능)

String appKey = "d2bbd...........19c86c8b021";

// 유효성을 검증하기 위하여 아래와 같이 verifyCode를 생성한다. DigestUtils는 Apache의 commons-codec.jar 이 필요하다. 다른 md5 해시함수가 있다면 그것을 사용해도 무방하다.

String verifyCode = DigestUtils.md5Hex(appKey + mdUserName + seqId);

// 생성한 verifyCode와 chk_cd 파라메터 값이 일치하지 않으면 잘못된 요청이다.

if (checkCode == null || !checkCode.equals(verifyCode)) {

    // 오류

    log.error("tnkad() check error : " + verifyCode + " != " + checkCode);

} else {

    log.debug("tnkad() : " + mdUserName + ", " + seqId);


    // 포인트 부여하는 로직수행 (예시)

    purchaseManager.getPointByAd(mdUserName, payPoint, seqId);

}
```



