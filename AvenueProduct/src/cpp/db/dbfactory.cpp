#include "dbfactory.h"
#include "dbserviceclient.h"

#include <QDebug>
#include "assert.h"

namespace db
{

DbFactory::DbFactory(QObject *parent)
{
    Q_UNUSED(parent)
}

DbFactory::~DbFactory()
{
}

//-----------------------------------------------------------------

QObject *DbFactory::createDbClient() const
{
    qDebug() << "DbFactory::createDbClient";
    DbServiceClient *ptr(new DbServiceClient());
    assert(ptr);
    return ptr;
}

//-----------------------------------------------------------------


}    // namespace db



