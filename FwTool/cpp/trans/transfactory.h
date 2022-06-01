#ifndef TRANSFACTORY_H
#define TRANSFACTORY_H

#include <QObject>
#include <QSharedPointer>

#include "ilevel2.h"
#include "serialclient.h"

namespace trans
{

class TransFactory : public QObject
{
    Q_OBJECT

private:
    QList<ILevel2 *>       m_listLvl2;
    QList<SerialClient *>  m_listClient;

private:
    TransFactory(const TransFactory&);
    TransFactory& operator=(const TransFactory&);

public:
    explicit TransFactory(QObject *parent = nullptr);
    ~TransFactory();

signals:

public slots:
    QObject* createObject();
    QObject* createSerialClient(const QString &mode);
};


}    // namespace trans


#endif // TRANSFACTORY_H
