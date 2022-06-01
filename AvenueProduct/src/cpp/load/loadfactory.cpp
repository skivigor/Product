#include "loadfactory.h"

#include <QDebug>
#include "assert.h"

namespace load
{

StandFactory::StandFactory(QObject *parent)
{
    Q_UNUSED(parent);
}

StandFactory::~StandFactory()
{
    for (int i = 0; i < m_listLdr.size(); ++i) delete m_listLdr.at(i);
}

//-----------------------------------------------------------------

QObject *StandFactory::createFwLoader(const QString &cfgPath, const QString &fwPath)
{
    qDebug() << "LoadFactory::createFwLoader";

    FwLoader *ptr(new FwLoader(cfgPath, fwPath));
    assert(ptr);
    m_listLdr.append(ptr);
    return ptr;
}

//-----------------------------------------------------------------

}    // namespace load

