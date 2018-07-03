import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.3
import QtQuick.XmlListModel 2.0
import QtPositioning 5.8
import net.ekotuki 1.0

import "pages"
import "components"
import "models"

ApplicationWindow {
    id: root
    visible: true
    width: 480
    height: 800
    title: appName

    property bool isLogged: false
    property bool debugBuild: true

    property bool updateAvailable: false

    property bool settingsDevelopmentMode: false
    property bool settingsKeepImages: true
    property bool settingsAskMultiple: true

    property ServerApi api: api
    property alias colorModel: colorModel
    property alias purposeModel: purposeModel

    property alias busy: api.busy

    property Position myPosition;
    property int savedLocation: 0

    onBusyChanged: {
        console.debug("*** BUSY"+busy)
    }

    onClosing: {
        console.debug("Closing!")
    }

    onMyPositionChanged: {
        var lm=api.getLocationsModel();
        if (myPosition.latitudeValid && myPosition.longitudeValid)
            lm.setPosition(myPosition.coordinate.latitude, myPosition.coordinate.longitude)
    }

    onSavedLocationChanged: console.debug("SLOC: "+savedLocation)

    function logout() {
        api.logout();
        isLogged=false;
        settings.setSettingsStr("password", "");
        rootStack.clear();
        rootStack.push(messagesView);
    }

    Component.onCompleted: {
        settingsDevelopmentMode=settings.getSettingsBool("developmentMode", false);
        settingsAskMultiple=settings.getSettingsBool("askMultiple", true);
        settingsKeepImages=settings.getSettingsBool("keepImages", true);

        savedLocation=settings.getSettingsInt("location", 0);

        if (userData.username!=='' && userData.password!=='')
            loginTimer.start();
    }

    onSettingsDevelopmentModeChanged: settings.setSettings("developmentMode", settingsDevelopmentMode)
    onSettingsAskMultipleChanged: settings.setSettings("askMultiple", settingsAskMultiple)
    onSettingsKeepImagesChanged: settings.setSettings("keepImages", settingsKeepImages)

    Timer {
        id: loginTimer
        interval: 100
        repeat: false;
        onTriggered: {
            var r=api.login();
            if (r===false) {
                messagePopup.show("Login", "Invalid login credentials");
            }
        }
    }

    PositionSource {
        id: geo
        updateInterval: 60000
        active: true

        onPositionChanged: {
            var coord = geo.position.coordinate;
            console.log("Coordinate:", coord.longitude, coord.latitude);
            myPosition=geo.position;
        }
    }

    header: rootStack.depth<2 ? mainToolbar : (rootStack.currentItem.header ? null : mainToolbar)

    ToolBar {
        id: mainToolbar
        enabled: !api.busy
        RowLayout {
            anchors.fill: parent
            ToolButton {
                contentItem: Image {
                    fillMode: Image.Pad
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    source: "qrc:/images/icon_menu.png"
                }
                visible: rootStack.depth==1
                onClicked: {
                    mainDrawer.open();
                }
            }

            ToolButton {
                id: backButton
                enabled: !api.busy // XXX We need to be able to somehow block back button in some cases, how ?
                contentItem: Image {
                    fillMode: Image.Pad
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    source: "qrc:/images/icon_back.png"
                    opacity: parent.enabled ? 1.0 : 0.8
                }
                visible: rootStack.depth>1
                onClicked: {
                    rootStack.pop()
                }
            }

            Label {
                id: currentPageTitle
                text: rootStack.currentItem ? rootStack.currentItem.title : ' '
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                font.pixelSize: 22
                minimumPixelSize: 16
                fontSizeMode: Text.HorizontalFit
            }

            ToolButton {
                enabled: !api.busy && rootStack.currentItem && rootStack.currentItem.objectName=="search"
                contentItem: Image {
                    fillMode: Image.Pad
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    source: "qrc:/images/icon_search.png"
                }
                visible: isLogged && rootStack.currentItem && rootStack.currentItem.objectName=="search"
                onClicked: {
                    rootStack.currentItem.toggleSearch()                    
                }
            }

            ToolButton {
                contentItem: Image {
                    fillMode: Image.Pad
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    source: "qrc:/images/icon_menu_2.png"
                }

                onClicked: mainMenu.open();
                Menu {
                    id: mainMenu
                    x: parent.width - width
                    transformOrigin: Menu.TopRight
                    modal: true
                    MenuItem {
                        enabled: rootStack.currentItem && rootStack.currentItem.objectName!='login'
                        text: !isLogged ? qsTr("Login") : qsTr("Logout")
                        onTriggered: {
                            if (!isLogged)
                                rootStack.push(pageLogin)
                            else
                                logout();
                        }
                    }
                    MenuItem {
                        text: qsTr("Settings")
                        enabled: rootStack.currentItem && rootStack.currentItem.objectName!='settings'
                        onTriggered: {
                            rootStack.push(pageSettings)
                        }
                    }
                    MenuItem {
                        text: qsTr("Exit")
                        onTriggered: Qt.quit(); // XXX And confirmation
                    }
                }
            }
        }
    }

    Drawer {
        id: mainDrawer
        height: root.height
        width: root.width/1.5
        dragMargin: rootStack.depth > 1 ? 0 : Qt.styleHints.startDragDistance
        ColumnLayout {
            anchors.fill: parent
            spacing: 16
            Image {
                Layout.fillWidth: true
                source: "/images/logo.png"
                fillMode: Image.PreserveAspectFit
            }

            Label {
                Layout.fillWidth: true
                visible: isLogged
                anchors.margins: 8
                font.pixelSize: 22
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: qsTr("Welcome")
            }

            Label {
                Layout.fillWidth: true
                visible: isLogged
                anchors.margins: 8
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: userData.username
            }

            Label {
                Layout.fillWidth: true
                visible: settingsDevelopmentMode
                anchors.margins: 16
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.Wrap
                text: "DEBUG MODE"
                color: "#ff0000"
            }

            Label {
                Layout.fillWidth: true
                visible: !isLogged
                anchors.margins: 16
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.Wrap
                text: qsTr("Not logged in")
            }

            ListView {
                id: mainActionList
                currentIndex: -1;
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true
                delegate: ItemDelegate {
                    width: parent.width
                    text: model.title
                    font.pointSize: 22;
                    //highlighted: ListView.isCurrentItem
                    onClicked: {
                        console.debug("DrawerMenu click: "+model.viewId)
                        if (mainActionList.currentIndex != index) {
                            mainActionList.currentIndex = index
                            rootStack.setView(model.viewId)
                        }
                        mainDrawer.close()
                    }
                }

                model: isLogged ? actionModel1 : actionModel2

                onModelChanged: {
                    currentIndex=-1;
                }

                ScrollIndicator.vertical: ScrollIndicator { }
            }

            Label {
                Layout.fillWidth: true
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "v"+appVersion
            }

        }
    }

    // XXX: Check user level and return true if allowed, false otherwise
    function checkUserRole(role) {
        return true;
    }

    // Main views when logged in
    ListModel {
        id: actionModel1
        ListElement { title: qsTr("Products"); viewId: 4; roles: 1; image: "qrc:/images/icon_browse.png"}
        ListElement { title: qsTr("Add product"); viewId: 3; roles: 2; image: "qrc:/images/icon_add.png" }

        ListElement { title: qsTr("Order"); viewId: 8; roles: 3; image: "" }
        ListElement { title: qsTr("Orders"); viewId: 9; roles: 3; image: "" }

        ListElement { title: qsTr("Messages"); viewId: 10; roles: 0; image: "" }

        //ListElement { title: qsTr("Help"); viewId: 6; roles: 0; image: "qrc:/images/icon_help.png" }
        ListElement { title: qsTr("About"); viewId: 7; roles: 0; image: "qrc:/images/icon_about.png" }
    }

    // Main views when logged out
    ListModel {
        id: actionModel2
        ListElement { title: qsTr("Login"); viewId: 1; roles: 0; image: "qrc:/images/icon_login.png" }
        //ListElement { title: qsTr("Help"); viewId: 6; roles: 0; image: "qrc:/images/icon_help.png" }
        ListElement { title: qsTr("Messages"); viewId: 10; roles: 0; image: "" }
        ListElement { title: qsTr("About"); viewId: 7; roles: 0; image: "qrc:/images/icon_about.png" }
    }

    // Our root navigation element
    StackView {
        id: rootStack
        anchors.fill: parent
        initialItem: mainView
        focus: true;
        onCurrentItemChanged: {
            console.debug("*** view is "+currentItem)            
            mainActionList.currentIndex=-1
            if (currentItem)
                currentItem.forceActiveFocus();
        }

        function setView(vid) {
            switch (vid) {
            case 1: // Login
                return rootStack.push(pageLogin)
            case 2: // Search
            case 4: // Browse
                if (rootStack.currentItem && rootStack.currentItem.objectName=="search")
                    return false;
                else
                    return rootStack.replace(null, searchView)
            case 3: // Add
                return rootStack.push(addView)
            case 5: // ????
                return rootStack.push(feedbackView)
            case 6: // Help
                return rootStack.push(helpView)
            case 7: // About
                return rootStack.push(aboutView)
            case 8: // Order
                return rootStack.push(orderView)
            case 9: // Orders
                return rootStack.push(ordersView)
            case 10:
                return rootStack.push(messagesView)
            default:
                console.debug("Unknown view requested!")
            }
        }

        function isView(view, current) {
            return (current===view) ? true : false;
        }

    }

    // XXX
    function showProduct(sku) {
        rootStack.push(searchView, { "searchString": sku }, StackView.Immediate)
    }

    Component {
        id: mainView
        PageMain {

        }
    }

    Component {
        id: messagesView
        PageMessages {
            newsModel: newsFeedModel
        }
    }

    Component {
        id: feedbackView
        Page {

        }
    }

    Component {
        id: helpView
        PageHelp {

        }
    }

    Component {
        id: aboutView
        PageAbout {

        }
    }

    Component {
        id: searchView
        PageSearch {
            id: psc
            onSearchRequested: {
                var r=root.api.products(1, 0, category, str);
                if (r)
                    setSearchActive();
            }

            onSearchBarcodeRequested: {
                var r=api.searchBarcode(barcode);
                if (r)
                    setSearchActive(r);
            }

            onRequestLoadMore: {
                if (!root.api.products(0, 0, category, str))
                    console.debug("Failed to load more")
                else
                    setSearchActive(false);
            }

            Component.onCompleted: {
                root.api.products(1);
            }

            Connections {
                target: api
                onSearchCompleted: {
                    setSearchActive(false);
                }
                onProductNotFound: {
                    searchBarcodeNotFound();
                }
            }
        }
    }

    Component {
        id: orderView
        PageOrder {
            onSearchBarcodeRequested: {
                var r=api.searchBarcode(barcode);
                if (r)
                    setSearchActive(r);
            }
            Connections {
                target: api
                onProductNotFound: {
                    setSearchActive(false);
                    searchBarcodeNotFound();
                }
                onSearchCompleted: {
                    setSearchActive(false);
                    searchComplete();
                }
                onOrderCreated: {
                    orderCreated();
                    messagePopup.show(qsTr("Order"), qsTr("Order created successfully"));
                }
            }
        }
    }

    Component {
        id: ordersView
        PageOrders {

        }
    }

    Component {
        id: camera
        CameraPage {

        }
    }

    Component {
        id: addView
        PageProductEdit {
            id: editPage
            defaultWarehouse: root.savedLocation
            keepImages: settingsKeepImages
            addMoreEnabled: settingsAskMultiple

            property Product tempProduct;

            onRequestProductSave: {
                tempProduct=editPage.createProduct();
                if (!tempProduct) {
                    console.debug("*** Failed to get product!")
                    editPage.saveFailed();
                    return;
                }

                var rs=api.add(tempProduct);
                if (rs)
                    editPage.saveInProgress();
                else
                    editPage.saveFailed();
            }
            Connections {
                target: api
                onProductSaved: {
                    if (editPage.confirmProductSave(true, null, "")) {
                        tempProduct.removeImages();
                    }
                    tempProduct.destroy();
                }
                onProductFail: {
                    editPage.confirmProductSave(false, null, msg);
                    tempProduct.destroy();
                }
            }

            onLocationIDChanged: {
                if (locationID==0)
                    return;
                if (locationID==root.savedLocation)
                    return;

                console.debug("Saving location "+locationID);
                settings.setSettings("location", locationID);
                root.savedLocation=locationID;
            }

            Component.onCompleted: {
                console.debug("Setting location information "+locationID)
                //locationID=settings.getSettingsInt("location", 0);
                api.getLocationsModel().clearFilter();
                locationsModel=api.getLocationsModel();
                console.debug("..done")
            }
        }
    }

    Component {
        id: pageLogin
        PageLogin {
            id: pageLoginPage
            objectName: "login"
            onLoginRequested: {
                userData.username=username;
                userData.password=password;
                settings.setSettingsStr("username", username);
                settings.setSettingsStr("password", password);
                loginTimer.start();
            }
            onLoginCanceled: {
                rootStack.pop();
            }
            Component.onCompleted: {
                // Fill in stored data
                username=userData.username;
                password=userData.password;
            }
        }
    }

    Component {
        id: pageSettings
        PageSettings {
            developmentMode: settingsDevelopmentMode
            keepImages: settingsKeepImages
            askMultiple: settingsAskMultiple

            onDevelopmentModeChanged: {
                settingsDevelopmentMode=developmentMode
            }
            onKeepImagesChanged: {
                settingsKeepImages=keepImages
            }
            onAskMultipleChanged: {
                settingsAskMultiple=askMultiple
            }
        }
    }

    MessageDialog {
        id: nyaDialog
        standardButtons: StandardButton.Ok
        title: "Not yet implemented"
        text: "Function is not yet implemented"

        onAccepted: {
            console.debug("*** Dialog accepted");
            nyaDialog.close();
        }
    }

    MessagePopup {
        id: messagePopup
    }

    MessagePopup {
        id: updatePopup
        onClosed: {
            rootStack.push(aboutView)
        }
    }


    // XXX, should we hardcode values here and map these on the server side or what ?
    // cid: server side identifier
    ColorModel {
        id: colorModel
    }

    PurposeModel {
        id: purposeModel
    }

    NewsModel {
        id: newsFeedModel
        source: api.url+"news"
    }

    LatestProductsModel {
        id: latestProductsModel
        source: api.url+"product/latest"
    }

    ServerApi {
        id: api
        url: settingsDevelopmentMode ? userData.urlSandbox : userData.urlProduction
        username: userData.username;
        password: userData.password;
        apikey: userData.apikey;

        onLoginSuccesfull: {
            console.debug("Login succesfull")
            isLogged=true;
            if (rootStack.contains(pageLogin)) {
                rootStack.pop();
            }
            rootStack.clear();
            rootStack.push(searchView)
            requestLocations();
            requestCategories();
        }

        onUpdateAvailable: {
            console.debug("UpdateAvailable")
            root.updateAvailable=true;
            updatePopup.show(qsTr("Update available"), qsTr("An application update is available"));
        }

        onUpdateDownloaded: {
            Qt.openUrlExternally("file://"+file);
        }

        onProductSaved: {
            console.debug("*** ProductSaved")
        }

        onProductFail: {
            console.debug("*** ProductFailed "+error)
            if (rootStack.currentItem.objectName=="productEdit")
                rootStack.currentItem.confirmProductSave(false, 0, msg);
        }

        onProductsFail: {
            console.debug("*** ProductsFailed "+error)
        }

        onLoginFailure: {
            console.debug("Login failure: "+msg)
            isLogged=false;
            if (rootStack.currentItem.objectName=="login") {
                rootStack.currentItem.reportLoginFailed();
            }
            if (code==500) {
                messagePopup.show(qsTr("Authentication Failure"), qsTr("Application authentication failed")+"\n\n"+msg)
            } else {
                messagePopup.show(qsTr("Authentication Failure"), qsTr("Login failed, check username and password")+"\n\n"+msg)
            }
        }

        onRequestFailure: {
            console.debug("*** FAIL: "+error)
            switch (error) {
            case 401:
            case 403:
                messagePopup.show(qsTr("Authentication Failure"), qsTr("Request is not authorized"));
                break;
            case 404:
                messagePopup.show(qsTr("Failure"), qsTr("Requested item does not exist"));
                break;
            case 500:
            default:
                messagePopup.show("Failure ("+error+")", "Internal network request failure!\n(Error '"+msg+"')");
            }

            // XXX: This should not be required
            if (rootStack.currentItem.objectName=="productEdit")
                rootStack.currentItem.confirmProductSave(false, 0, msg);
        }

        onSecureConnectionFailure: {
            messagePopup.show("Failure", "Secure network request failure!");
        }

        onRequestSuccessful: {
            console.debug("*** OK")
        }

        Component.onCompleted: {
            setAppVersion(appVersionCode);
        }

    }
}
