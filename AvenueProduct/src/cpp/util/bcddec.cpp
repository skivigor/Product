#include "bcddec.h"

namespace util
{

quint8 ByteToBcd2(quint8 Value)
{
    quint32 bcdhigh = 0U;

    while(Value >= 10U)
    {
        bcdhigh++;
        Value -= 10U;
    }

    return  ((quint8)(bcdhigh << 4U) | Value);
}

//-----------------------------------------------------------------

quint8 Bcd2ToByte(quint8 Value)
{
    quint32 tmp = 0U;
    tmp = ((quint8)(Value & (quint8)0xF0U) >> (quint8)0x4U) * 10U;
    return (tmp + (Value & (quint8)0x0FU));
}

}    // namespace util
