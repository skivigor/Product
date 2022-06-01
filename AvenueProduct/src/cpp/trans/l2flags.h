#ifndef L2FLAGS_H
#define L2FLAGS_H

#include <QObject>
#include "ilevel2.h"

#include <QTimer>

namespace trans
{

class L2Flags : public QObject, public ILevel2
{
    Q_OBJECT

private:
    const quint8   m_flag;
    QByteArray     m_queue;
    QTimer         m_timer;

private slots:
    void onTimeout();

public:
    explicit L2Flags(quint8 flag, QObject *parent = nullptr);

    // ILevel2 implementation
    QByteArray packData(const QByteArray &data);
    QByteArrayList unpackData(const QByteArray &data);
};


}    // namespace trans


#endif // L2FLAGS_H
