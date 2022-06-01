#ifndef ICONNECTION_H
#define ICONNECTION_H

#include <QByteArray>
#include "iprotocoll2.h"

namespace trans
{

class IConnection
{
private:
    IProtocolL2  &m_protocol;

public:
    IConnection(IProtocolL2 &protocol) : m_protocol(protocol) {}
    virtual ~IConnection() {}

    // Slots
    void sendData(const QByteArray &data);

    // Signals
    void rcvData(const QByteArray &data);
};


}    // namespace trans


#endif // ICONNECTION_H
