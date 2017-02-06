#include "productitem.h"

#include <QDebug>

ProductItem::ProductItem(QObject *parent) : QObject(parent)
{

}

ProductItem::ProductItem(const QString &barcode, const QString &title, const QString &description, QObject *parent)
{
    m_barcode=barcode;
    m_title=title;
    m_description=description;
    m_stock=1;
}

ProductItem* ProductItem::fromVariantMap(QVariantMap &data, QObject *parent)
{
    ProductItem *p=new ProductItem(parent);

    qDebug() << data;

    p->setBarcode(data["barcode"].toString());
    p->setTitle(data["title"].toString());
    p->setCategory(data["category"].toString());
    p->setSubCategory(data["subcategory"].toString());

    p->m_id=data["id"].toString().toInt();
    if (p->m_id==0)
        qWarning("Failed to get product ID");

    p->m_uid=data["uid"].toString().toDouble();

    if (data.contains("stock"))
        p->m_stock=data["stock"].toString().toDouble();
    else
        p->m_stock=1;

    if (data.contains("images"))
        p->setImages(data["images"].toList());

    if (data.contains("size")) {
        QVariantMap sm=data["size"].toMap();
        if (sm.contains("weight"))
            p->setAttribute("weight", sm["weight"].toString().toDouble());
        if (sm.contains("depth"))
            p->setAttribute("depth", sm["depth"].toString().toDouble());
        if (sm.contains("width"))
            p->setAttribute("width", sm["width"].toString().toDouble());
        if (sm.contains("height"))
            p->setAttribute("height", sm["height"].toString().toDouble());
    }

    // XXX: Loop over valid attributes ?

    if (data.contains("color"))
        p->setAttribute("color", data["color"].toString().toDouble());

    if (data.contains("purpose"))
        p->setAttribute("purpose", data["purpose"].toString().toDouble());

    if (data.contains("material"))
        p->setAttribute("materil", data["material"].toString().toDouble());

    if (data.contains("ean"))
        p->setAttribute("ean", data["ean"].toString());

    if (data.contains("isbn"))
        p->setAttribute("isbn", data["isbn"].toString());

    return p;
}

ProductItem::~ProductItem()
{
    qDebug() << "*** Delete Product " << m_barcode;
}

uint ProductItem::getID() const
{
    return m_id;
}

uint ProductItem::getOwner() const
{
    return m_uid;
}

uint ProductItem::getStock() const
{
    return m_stock;
}


const QString ProductItem::getBarcode() const
{
    return m_barcode;
}

const QString ProductItem::getTitle() const
{
    return m_title;
}

const QString ProductItem::getDescription() const
{
    return m_description;
}

QString ProductItem::thumbnail() const
{
    if (m_images.size()>0)
        return m_images.at(0).toString();
    return "";
}

bool ProductItem::hasAttribute(const QString key) const
{
    return m_attributes.contains(key);
}

bool ProductItem::hasAttributes() const
{
    return m_attributes.size()==0 ? false : true;
}

QVariant ProductItem::getAttribute(const QString key) const
{
    return m_attributes.value(key);
}

void ProductItem::setAttribute(const QString key, const QVariant value)
{
    m_attributes.insert(key, value);
    emit attributesChanged(key, value);
}

void ProductItem::setStock(uint stock)
{
    if (m_stock==stock)
        return;

    m_stock=stock;
    emit stockChanged(stock);
}

void ProductItem::setTitle(QString title)
{
    if (m_title == title)
        return;

    m_title = title;
    emit titleChanged(title);
}

void ProductItem::setBarcode(QString barcode)
{
    if (m_barcode == barcode)
        return;

    m_barcode = barcode;
    emit barcodeChanged(barcode);
}

void ProductItem::setDescription(QString description)
{
    if (m_description == description)
        return;

    m_description = description;
    emit descriptionChanged(description);
}

void ProductItem::addImage(const QVariant image)
{
    m_images.append(image);
    emit imagesChanged(m_images);
}

void ProductItem::setImages(QVariantList images)
{
    if (m_images == images)
        return;

    m_images = images;
    emit imagesChanged(images);
    if (images.size()>0)
        emit thumbnailChanged(images.at(0).toString());
    else
        emit thumbnailChanged("");
}

void ProductItem::setCategory(const QString category)
{
    if (m_category == category)
        return;

    m_category = category;
    emit categoryChanged(category);
}

void ProductItem::setSubCategory(const QString category)
{
    if (m_subcategory == category)
        return;

    m_subcategory = category;
    emit subCategoryChanged(category);
}
