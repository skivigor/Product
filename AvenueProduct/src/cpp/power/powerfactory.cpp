#include "powerfactory.h"
#include "pwrsupply.h"
#include "conntcp.h"

#include <QDebug>
#include "assert.h"

namespace power
{

PowerFactory::PowerFactory(QObject *parent)
{
    Q_UNUSED(parent)
}

PowerFactory::~PowerFactory()
{
}

//-----------------------------------------------------------------

QObject *PowerFactory::createPowerSupplyWithTcp(const QString &uri, int port)
{
    ConnTcp *tcp = new ConnTcp(uri, port);
    assert(tcp);
//    ProtocolLevel2 *l2 = new ProtocolLevel2(*tcp);
//    assert(l2);
    PwrSupply *pw = new PwrSupply(*tcp);
    assert(pw);

    return pw;
}

//-----------------------------------------------------------------

}   // namespace power

