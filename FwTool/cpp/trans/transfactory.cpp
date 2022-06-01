#include "transfactory.h"
#include "l2flags.h"
#include "l2stuffbytes.h"
#include "l2empty.h"

#include <QDebug>
#include "assert.h"

namespace trans
{

TransFactory::TransFactory(QObject *parent)
{
    Q_UNUSED(parent)
}

TransFactory::~TransFactory()
{
    for (int i = 0; i < m_listClient.size(); ++i) delete m_listClient.at(i);
    for (int i = 0; i < m_listLvl2.size(); ++i) delete m_listLvl2.at(i);
}

//-----------------------------------------------------------------

QObject *TransFactory::createObject()
{
    qDebug() << "TransFactory::createObject";

    L2Flags *l2 = new L2Flags(0xFF);
    SerialClient *cl = new SerialClient(*l2);

    m_listLvl2.append(l2);
    m_listClient.append(cl);

    qDebug() << "TransFactory::createObject: ptr " << cl;

    return cl;
}

//-----------------------------------------------------------------

QObject *TransFactory::createSerialClient(const QString &mode)
{
    qDebug() << "TransFactory::createSerialClient";

    ILevel2 *l2(nullptr);
    SerialClient *cl(nullptr);

    if (mode == "flag") l2 = new L2Flags(0xFF);
    if (mode == "stuff") l2 = new L2StuffBytes(0xE1, 0xE2, 0xEF);
    if (mode == "string") { }
    if (l2 == nullptr) l2 = new L2Empty();
    assert(l2);

    cl = new SerialClient(*l2);
    assert(cl);

    m_listLvl2.append(l2);
    m_listClient.append(cl);
    return cl;
}

//-----------------------------------------------------------------

}    // namespace trans

