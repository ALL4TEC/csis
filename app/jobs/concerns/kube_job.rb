# frozen_string_literal: true

# Contains all required data to launch a job managed by k8s
module KubeJob
  extend ActiveSupport::Concern

  const_set(:REGISTRY, ENV.fetch('REGISTRY', ''))
  const_set(:INSTANCE_NAME, ENV.fetch('INSTANCE_NAME', 'undefined'))
  const_set(:VERSION, ENV.fetch('CONTAINER_IMAGE', CSIS::VERSION))
  const_set(:NAMESPACE, ENV.fetch('NAMESPACE', 'default'))
  const_set(:SERVICE_ACCOUNT, ENV.fetch('SERVICE_ACCOUNT', 'csis-sa'))

  included do
    include Kubernetes::Job

    def manifest
      YAML.safe_load(
        <<~MANIFEST
          apiVersion: batch/v1
          kind: Job
          metadata:
            name: #{INSTANCE_NAME}-queue # worker-job
            namespace: #{NAMESPACE}
          spec:
            template:
              metadata:
                labels:
                  component: #{INSTANCE_NAME}-queue
              spec:
                serviceAccountName: #{SERVICE_ACCOUNT}
                containers:
                - args:
                  - bundle
                  - exec
                  - rails
                  - environment
                  - resque:work
                  name: csis-resque-worker
                  image: #{REGISTRY}:#{VERSION}
                  imagePullPolicy: Always
                  env:
                  - name: RAILS_MASTER_KEY
                    valueFrom:
                      secretKeyRef:
                        key: rails_master_key
                        name: rails-secrets
                  - name: QUEUE
                    value: '*'
                  - name: GNUPGHOME
                    value: gpg
                  envFrom:
                  - configMapRef:
                      name: env-#{INSTANCE_NAME}
                  - secretRef:
                      name: mail-secret
                  volumeMounts:
                  - mountPath: /var/www/csis/public
                    name: assets-storage
                  - mountPath: /var/www/csis/storage
                    name: storage-storage
                  - mountPath: /var/www/csis/gpg
                    name: gpg-storage
                volumes:
                - name: assets-storage
                  persistentVolumeClaim:
                    claimName: #{INSTANCE_NAME}-assets-pvc
                - name: storage-storage
                  persistentVolumeClaim:
                    claimName: #{INSTANCE_NAME}-storage-pvc
                - name: gpg-storage
                  persistentVolumeClaim:
                    claimName: #{INSTANCE_NAME}-gpg-pvc
        MANIFEST
      )
    end
  end
end
