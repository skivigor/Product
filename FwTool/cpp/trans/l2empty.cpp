#include "l2empty.h"

namespace trans
{

L2Empty::L2Empty()
{
}

//-----------------------------------------------------------------

QByteArray L2Empty::packData(const QByteArray &data)
{
    return data;
}

//-----------------------------------------------------------------

QByteArrayList L2Empty::unpackData(const QByteArray &data)
{
    QByteArrayList list;
    list.append(data);
    return list;
}

//-----------------------------------------------------------------

}    // namespace trans

