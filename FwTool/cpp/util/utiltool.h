#ifndef UTILTOOL_H
#define UTILTOOL_H

#include <QObject>

namespace util
{

class UtilTool : public QObject
{
    Q_OBJECT
public:
    explicit UtilTool(QObject *parent = nullptr);
    ~UtilTool();

signals:

public slots:
    void wait(int ms) const;
};


}   // namespace util


#endif // UTILTOOL_H
