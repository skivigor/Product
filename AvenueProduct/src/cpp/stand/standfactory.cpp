#include "standfactory.h"
#include "stand.h"
#include "scanner.h"

#include <QDebug>
#include "assert.h"

namespace stand
{

StandFactory::StandFactory(QObject *parent)
{
    Q_UNUSED(parent)
}

StandFactory::~StandFactory()
{
}


//-----------------------------------------------------------------

QObject *StandFactory::createStand()
{
    qDebug() << "StandFactory::createStand";
    Stand *ptr(new Stand());
    assert(ptr);
    return ptr;
}

//-----------------------------------------------------------------

QObject *StandFactory::createScanner()
{
    qDebug() << "StandFactory::createScanner";
    Scanner *ptr(new Scanner());
    assert(ptr);
    return ptr;
}

//-----------------------------------------------------------------

}    // namespace stand

