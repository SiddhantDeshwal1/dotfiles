function Alpha
    # 1. Mount the drive silently using its label
    udisksctl mount -b /dev/disk/by-label/Alpha > /dev/null 2>&1
    
    # 2. Jump into the folder (udisks2 always uses this path structure)
    cd /run/media/apple/Alpha/
end
