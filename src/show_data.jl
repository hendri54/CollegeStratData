function settings_table(ds :: DataSettings)
    borrowLimitV = borrow_limits(ds, modelUnits = false);
    borrowLimitV = round.(borrowLimitV, digits = 0);
    return [
        "Data"  " ";
        "Borrowing limits"  "$borrowLimitV"
    ]
end

# -----------