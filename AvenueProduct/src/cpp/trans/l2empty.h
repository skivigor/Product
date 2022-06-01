#ifndef L2EMPTY_H
#define L2EMPTY_H

#include "ilevel2.h"

namespace trans
{

class L2Empty : public ILevel2
{

public:
    explicit L2Empty();

    // ILevel2 implementation
    QByteArray packData(const QByteArray &data);
    QByteArrayList unpackData(const QByteArray &data);
};


}    // namespace trans


#endif // L2EMPTY_H
