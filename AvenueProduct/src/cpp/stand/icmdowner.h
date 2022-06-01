#ifndef ICMDOWNER_H
#define ICMDOWNER_H

#include <QByteArray>

class ICmdOwner
{
public:
    virtual ~ICmdOwner() {}

    virtual void onRcvData(const QByteArray &data) = 0;
};

#endif // ICMDOWNER_H
