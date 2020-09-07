#include "xfifo.h"
#include "xfifo_g.c"

int XFIFO_CfgInitialize(XFIFO *InstancePtr, XFIFO_Config *ConfigPtr)
{
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    if (InstancePtr->IsStarted == XIL_COMPONENT_IS_STARTED)
    {
        return XST_DEVICE_IS_STARTED;
    }
    InstancePtr->Config.DeviceId = ConfigPtr->DeviceId;
    InstancePtr->Config.BaseAddr = ConfigPtr->BaseAddr;
    InstancePtr->IsStarted = 0;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}

void XFIFO_Reset(XFIFO *InstancePtr, u32 Mode)
{
    u32 addr = InstancePtr->Config.BaseAddr;
    XFIFO_WriteReg(
        addr,
        XFIFO_STATUS_WR_OFFSET,
        XFIFO_SetStatus1(XFIFO_STATUS_RESET_MASK,
                         Mode));

    XFIFO_WriteReg(
        addr,
        XFIFO_STATUS_WR_OFFSET,
        XFIFO_SetStatus0(XFIFO_STATUS_RESET_MASK,
                         XFIFO_ReadReg(addr, XFIFO_STATUS_WR_OFFSET)));
}

uint32_t XFIFO_Pop(XFIFO *InstancePtr)
{
    u32 addr = InstancePtr->Config.BaseAddr;
    XFIFO_StartRead(addr);
    u32 value = XFIFO_ReadReg(addr, XFIFO_DATA_OFFSET);
    XFIFO_StopRead(addr);
    return value;
}

int XFIFO_Read(XFIFO *InstancePtr, u32 Data[], u32 Start, u32 End)
{
    u32 read = 0;
    u32 addr = InstancePtr->Config.BaseAddr;
    for (; read < End && !XFIFO_IsEmpty(addr); read++)
    {
        XFIFO_StartRead(addr);
        if (read >= Start)
        {
            Data[read - Start] = XFIFO_ReadReg(addr, XFIFO_DATA_OFFSET);
        }
        XFIFO_StopRead(addr);
    }
    return read - Start;
}

void XFIFO_WaitFull(XFIFO *InstancePtr)
{
    while (!XFIFO_IsFull(InstancePtr->Config.BaseAddr))
    {
    }
}