#include "l2flagsfa.h"

namespace trans
{

L2FlagsFA::L2FlagsFA(quint8 flag)
    : L2Flags (flag)
{
}

//-----------------------------------------------------------------

QByteArray L2FlagsFA::packData(const QByteArray &data)
{
    QByteArray ba = L2Flags::packData(data);
    ba.prepend(static_cast<char>(0xFA));
    return ba;
}

//-----------------------------------------------------------------

QByteArrayList L2FlagsFA::unpackData(const QByteArray &data)
{
    QByteArray ba = data.mid(4);
    return  L2Flags::unpackData(ba);
}

//-----------------------------------------------------------------

}    // namespace trans

