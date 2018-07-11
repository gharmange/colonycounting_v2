function structure = add_entry_to_structure(entry, structure)

    if any(structfun(@isempty, structure))
        structure = entry;
    else
        structure = [structure, entry];
    end

end