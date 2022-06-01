#ifndef L2FLAGSFA_H
#define L2FLAGSFA_H

#include "l2flags.h"

namespace trans
{

class L2FlagsFA : public L2Flags
{
public:
    explicit L2FlagsFA(quint8 flag);

    // ILevel2 implementation
    QByteArray packData(const QByteArray &data);
    QByteArrayList unpackData(const QByteArray &data);
};


}    // namespace trans


#endif // L2FLAGSFA_H
