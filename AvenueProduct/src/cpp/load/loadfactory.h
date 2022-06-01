#ifndef LOADFACTORY_H
#define LOADFACTORY_H

#include <QObject>

#include "fwloader.h"

namespace load
{

class StandFactory : public QObject
{
    Q_OBJECT

private:
    QList<FwLoader *>   m_listLdr;

private:
    StandFactory(const StandFactory&);
    StandFactory& operator=(const StandFactory&);

public:
    explicit StandFactory(QObject *parent = nullptr);
    ~StandFactory();

signals:

public slots:
    QObject *createFwLoader(const QString &cfgPath, const QString &fwPath);
};


}    // namespace load


#endif // LOADFACTORY_H
