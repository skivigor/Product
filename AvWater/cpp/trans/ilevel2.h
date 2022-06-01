#ifndef ILEVEL2_H
#define ILEVEL2_H

#include <QByteArray>
#include <QByteArrayList>
//#include <QList>

namespace trans
{

class ILevel2
{
public:
    virtual ~ILevel2() {}

    virtual QByteArray packData(const QByteArray &data) = 0;
    virtual QByteArrayList unpackData(const QByteArray &data) = 0;

};


}    // namepsace trans


#endif // ILEVEL2_H
