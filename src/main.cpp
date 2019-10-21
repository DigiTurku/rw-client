#include <QApplication>
#include <QDebug>

#include <QtQuick>
#include <QtQml>
#include <QQmlApplicationEngine>
#include <QQmlPropertyMap>

#include <QCamera>
#include <QCameraInfo>

#include <QSettings>
#include <QQuickStyle>
#include <QTranslator>

#include "src/barcodevideofilter.h"

#include "rwnetworkaccessmanagerfactory.h"
#include "rvapi.h"
#include "eanvalidator.h"
#include "itemlistmodel.h"
#include "settings.h"
#include "apputility.h"

#ifdef Q_OS_ANDROID
#include "androidhelper.h"
#include <QtAndroidExtras/QtAndroid>
#endif

#define VERSION "0.0.13"
#define VERSION_CODE 13

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    const QString appversion(VERSION);
    const QString apptitle(APP_TITLE);
    const int appvcode=VERSION_CODE;

    QCoreApplication::setOrganizationDomain(APP_DOMAIN);
    QCoreApplication::setOrganizationName(APP_ORG);
    QCoreApplication::setApplicationName(APP_NAME);
    QCoreApplication::setApplicationVersion(appversion);

    QQuickStyle::setStyle("Material");

    QTranslator translator;

    Settings settings;
    AppUtility apputil;

    QString locale(QLocale().name());

    qDebug() << "Locale is: " << locale;

    if (translator.load(QLocale(), QLatin1String("rw-client"), QLatin1String("_"), QLatin1String(":/translations")))
        app.installTranslator(&translator);
    else
        qDebug() << "Translation not available for locale " << locale;

    QQmlApplicationEngine engine;

    QQuickStyle::setStyle("Material");

    RWNetworkAccessManagerFactory *nam=new RWNetworkAccessManagerFactory();

    engine.setNetworkAccessManagerFactory(nam);

    qRegisterMetaType<OrganizationItem*>("OrganizationItem");
    qRegisterMetaType<OrganizationModel*>();

    qRegisterMetaType<ProductItem*>("ProductItem");
    qRegisterMetaType<LocationItem*>("LocationItem");
    qRegisterMetaType<OrderItem *>("OrderItem");
    qRegisterMetaType<OrderLineItem *>("OrderLineItem");

    qRegisterMetaType<QStringListModel*>();
    qRegisterMetaType<CategoryModel*>();
    qRegisterMetaType<ItemListModel*>();
    qRegisterMetaType<OrdersModel*>();
    qRegisterMetaType<OrderLineItemModel*>();
    qRegisterMetaType<LocationListModel*>();

    qRegisterMetaType<ColorItem*>("ColorItem");
    //qRegisterMetaType<ColorModel*>();

    qmlRegisterType<BarcodeVideoFilter>("net.ekotuki", 1,0, "BarcodeScanner");
    qmlRegisterType<ProductItem>("net.ekotuki", 1,0, "Product");
    qmlRegisterType<OrderItem>("net.ekotuki", 1,0, "OrderItem");
    qmlRegisterType<OrderLineItem>("net.ekotuki", 1,0, "OrderLineItem");
    qmlRegisterType<RvAPI>("net.ekotuki", 1,0, "ServerApi");
    qmlRegisterType<EANValidator>("net.ekotuki", 1,0, "EanValidator");

    qmlRegisterUncreatableType<CategoryModel>("net.ekotuki", 1, 0, "CategoryModel", "Used in C++ only");
    qmlRegisterUncreatableType<ItemListModel>("net.ekotuki", 1, 0, "ItemModel", "Used in C++ only");
    qmlRegisterUncreatableType<OrdersModel>("net.ekotuki", 1, 0, "OrderModel", "Used in C++ only");
    qmlRegisterUncreatableType<OrderLineItemModel>("net.ekotuki", 1, 0, "OrderLineItemModel", "Used in C++ only");
    qmlRegisterUncreatableType<ColorModel>("net.ekotuki", 1, 0, "ColorModel", "Used in C++ only");
    qmlRegisterUncreatableType<OrganizationModel>("net.ekotuki", 1, 0, "OrganizationModel", "Used in C++ only");

#ifdef Q_OS_ANDROID
    AndroidHelper android;
    engine.rootContext()->setContextProperty("android", &android);
#endif

    engine.rootContext()->setContextProperty("settings", &settings);
    engine.rootContext()->setContextProperty("appVersion", appversion);
    engine.rootContext()->setContextProperty("appName", QCoreApplication::applicationName());
    engine.rootContext()->setContextProperty("appTitle", apptitle);
    engine.rootContext()->setContextProperty("appVersionCode", appvcode);    
    engine.rootContext()->setContextProperty("appUtil", &apputil);

    // For setting API key for custom QtQuick NetworkAccessManagerFactory
    engine.rootContext()->setContextProperty("appNAM", nam);

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

#ifdef Q_OS_ANDROID
    QtAndroid::hideSplashScreen(250);
#endif

    return app.exec();
}
