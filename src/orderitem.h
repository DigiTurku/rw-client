#ifndef ORDERITEM_H
#define ORDERITEM_H

#include <QObject>
#include <QVariant>
#include <QDateTime>
#include <QMap>
#include <QPair>

class OrderItem : public QObject
{
    Q_OBJECT
    Q_ENUMS(OrderStatus)
    Q_PROPERTY(uint orderID MEMBER m_id NOTIFY orderIDChanged)
    Q_PROPERTY(uint uid MEMBER m_uid NOTIFY uidChanged)
    // Q_PROPERTY(QDateTime created READ created WRITE setCreated NOTIFY createdChanged)
public:
    explicit OrderItem(QObject *parent = nullptr);
    enum OrderStatus { Unknown=0, Cart, Cancelled, Pending, Shipped };

    static OrderItem *fromVariantMap(QVariantMap &data, QObject *parent);

    Q_INVOKABLE QStringList products();
    //Q_INVOKABLE QStringList product(const QString &sku);

signals:
    void orderIDChanged(uint orderID);
    void uidChanged(uint uid);

private:
    uint m_id;
    uint m_uid;
    OrderStatus m_status;
    QDateTime m_created;
    QDateTime m_changed;
    uint m_amount;

    // SKU -> Title,Amount
    QMap<QString, QPair<QString, int>> m_products;

    QVariantMap m_shipping;
    QVariantMap m_billing;
};

#endif // ORDERITEM_H
