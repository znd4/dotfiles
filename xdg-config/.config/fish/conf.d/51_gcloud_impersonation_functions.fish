set team mlops

function imp

    set project (
        gcloud projects list \
            --filter="name ~ $team-c" \
            --format="value(PROJECT_ID)" \
    )
    set service_account (
        gcloud iam service-accounts list \
            --filter="email ~ -developers@" \
            --format="value(email)" \
            --project=$project \
    )

    gcloud config set auth/impersonate_service_account $service_account

    echo "Started impersonating $service_account"

end

function unimp
    # Undo impersonation
    gcloud config unset auth/impersonate_service_account
    echo "Stopped impersonating"
end
