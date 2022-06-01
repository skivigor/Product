#ifndef IPROTOCOLL2_H
#define IPROTOCOLL2_H

class QByteArray;

namespace func
{
class JoobyLamp;
}    // namespace func

namespace trans
{

class IProtocolL2
{
protected:
    func::JoobyLamp  *m_lamp;

public:
    IProtocolL2() : m_lamp(nullptr) {}
    virtual ~IProtocolL2()  {}

    void setSender(func::JoobyLamp *lamp)  { m_lamp = lamp; }
    virtual void packData(QByteArray &data) = 0;
    virtual void unpackData(QByteArray &data) = 0;
};


}    // namespace trans

#endif // IPROTOCOLL2_H
